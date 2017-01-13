package main

import (
	"bufio"
	"fmt"
	"github.com/go-gl/gl/v2.1/gl"
	"github.com/go-gl/glfw/v3.2/glfw"
	"github.com/timshannon/go-openal/openal"
	"github.com/yuin/gopher-lua"
	"io/ioutil"
	"math"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	MaxSimul = 4
	FPS      = 60
	P1P3Dist = 25
)

var sys = System{
	randseed:  int32(time.Now().UnixNano()),
	scrrect:   [...]int32{0, 0, 320, 240},
	gameWidth: 320, gameHeight: 240,
	widthScale: 1, heightScale: 1,
	brightness: 256,
	roundTime:  -1,
	lifeMul:    1, team1VS2Life: 1,
	turnsRecoveryRate: 1.0 / 300,
	lifebarFontScale:  1,
	mixer:             *newMixer(),
	bgm:               *newVorbis(),
	sounds:            newSounds(),
	allPalFX:          *newPalFX(),
	bgPalFX:           *newPalFX(),
	sel:               *newSelect(),
	keySatate:         make(map[glfw.Key]bool),
	match:             1,
	listenPort:        "7500",
	loader:            *newLoader(),
	numSimul:          [...]int32{2, 2}, numTurns: [...]int32{2, 2},
	afterImageMax:          8,
	attack_LifeToPowerMul:  0.7,
	getHit_LifeToPowerMul:  0.6,
	superpmap:              *newPalFX(),
	super_TargetDefenceMul: 1.5,
	helperMax:              56,
	wincnt:                 wincntMap(make(map[string][]int32)),
	wincntFileName:         "autolevel.txt",
	powerShare:             [...]bool{true, true},
	eventKeys:              make(map[ShortcutKey]bool),
	hotkeys:                make(map[ShortcutKey]string),
	commandLine:            make(chan string),
	cam:                    *newCamera(),
	playerIdCache:          make(map[int32]*Char),
}

type TeamMode int32

const (
	TM_Single TeamMode = iota
	TM_Simul
	TM_Turns
	TM_LAST = TM_Turns
)

type System struct {
	randseed                int32
	scrrect                 [4]int32
	gameWidth, gameHeight   int32
	widthScale, heightScale float32
	window                  *glfw.Window
	gameEnd, frameSkip      bool
	redrawWait              struct{ nextTime, lastDraw time.Time }
	brightness              int32
	introTime, roundTime    int32
	lifeMul, team1VS2Life   float32
	turnsRecoveryRate       float32
	lifebarFontScale        float32
	debugFont               *Fnt
	debugScript             string
	debugDraw               bool
	mixer                   Mixer
	bgm                     Vorbis
	audioContext            *openal.Context
	nullSndBuf              [audioOutLen * 2]int16
	sounds                  Sounds
	allPalFX, bgPalFX       PalFX
	lifebar                 Lifebar
	sel                     Select
	keySatate               map[glfw.Key]bool
	netInput                *NetInput
	fileInput               *FileInput
	aiInput                 [MaxSimul * 2]AiInput
	keyConfig               []KeyConfig
	com                     [MaxSimul * 2]int32
	autolevel               bool
	home                    int
	gameTime                int32
	match                   int32
	inputRemap              [MaxSimul * 2]int
	listenPort              string
	round                   int32
	intro                   int32
	time                    int32
	winTeam                 int
	winType                 [2]WinType
	matchWins, wins         [2]int32
	roundsExisted           [2]int32
	draws                   int32
	loader                  Loader
	chars                   [MaxSimul * 2][]*Char
	charList                CharList
	cgi                     [MaxSimul * 2]CharGlobalInfo
	tmode                   [2]TeamMode
	numSimul, numTurns      [2]int32
	esc                     bool
	loadMutex               sync.Mutex
	ignoreMostErrors        bool
	stringPool              [MaxSimul * 2]StringPool
	bcStack, bcVarStack     BytecodeStack
	bcVar                   []BytecodeValue
	workingChar             *Char
	specialFlag             GlobalSpecialFlag
	afterImageMax           int
	attack_LifeToPowerMul   float32
	getHit_LifeToPowerMul   float32
	envShake                EnvShake
	pause                   int32
	pausetime               int32
	pausebg                 bool
	pauseendcmdbuftime      int32
	pauseplayer             int
	super                   int32
	supertime               int32
	superpausebg            bool
	superendcmdbuftime      int32
	superplayer             int
	superdarken             bool
	superanim               *Animation
	superpmap               PalFX
	superpos                [2]float32
	superfacing             float32
	superp2defmul           float32
	superunhittable         bool
	super_TargetDefenceMul  float32
	envcol                  [3]int32
	envcol_time             int32
	envcol_under            bool
	clipboardText           [MaxSimul * 2][]string
	stage                   *Stage
	helperMax               int32
	nextCharId              int32
	wincnt                  wincntMap
	wincntFileName          string
	powerShare              [2]bool
	tickCount               int
	oldTickCount            int
	tickCountF              float32
	lastTick                float32
	nextAddTime             float32
	oldNextAddTime          float32
	screenleft              float32
	screenright             float32
	xmin, xmax              float32
	winskipped              bool
	step                    bool
	roundResetFlg           bool
	reloadFlg               bool
	eventKeys               map[ShortcutKey]bool
	hotkeys                 map[ShortcutKey]string
	turbo                   float32
	commandLine             chan string
	drawScale               float32
	zoomPos                 [2]float32
	debugWC                 *Char
	cam                     Camera
	finish                  FinishType
	playerIdCache           map[int32]*Char
	waitdown                int32
	shuttertime             int32
	projs                   [MaxSimul * 2][]Projectile
	explods                 [MaxSimul * 2][]Explod
	explDrawlist            [MaxSimul * 2][]int
	topexplDrawlist         [MaxSimul * 2][]int
	changeStateNest         int32
	sprites                 []*SprData
	topSprites              []*SprData
	shadows                 []*ShadowSprite
	drawc1                  ClsnRect
	drawc2                  ClsnRect
	drawc2sp                ClsnRect
	drawwh                  ClsnRect
	autoguard               [MaxSimul * 2]bool
}

func (s *System) init(w, h int32) *lua.LState {
	glfw.WindowHint(glfw.Resizable, glfw.False)
	glfw.WindowHint(glfw.ContextVersionMajor, 2)
	glfw.WindowHint(glfw.ContextVersionMinor, 1)
	s.setWindowSize(w, h)
	var err error
	s.window, err = glfw.CreateWindow(int(s.scrrect[2]), int(s.scrrect[3]),
		"Ikemen GO", nil, nil)
	chk(err)
	s.window.MakeContextCurrent()
	s.window.SetKeyCallback(keyCallback)
	glfw.SwapInterval(1)
	chk(gl.Init())
	s.keyConfig = append(s.keyConfig, KeyConfig{-1,
		int(glfw.KeyUp), int(glfw.KeyDown), int(glfw.KeyLeft), int(glfw.KeyRight),
		int(glfw.KeyZ), int(glfw.KeyX), int(glfw.KeyC),
		int(glfw.KeyA), int(glfw.KeyS), int(glfw.KeyD), int(glfw.KeyEnter)})
	RenderInit()
	s.audioOpen()
	l := lua.NewState()
	l.OpenLibs()
	for i := range s.inputRemap {
		s.inputRemap[i] = i
	}
	for i := range s.stringPool {
		s.stringPool[i] = *NewStringPool()
	}
	systemScriptInit(l)
	go func() {
		stdin := bufio.NewScanner(os.Stdin)
		for stdin.Scan() {
			if err := stdin.Err(); err != nil {
				println(err)
				return
			}
			s.commandLine <- stdin.Text()
		}
	}()
	return l
}
func (s *System) setWindowSize(w, h int32) {
	s.scrrect[2], s.scrrect[3] = w, h
	if s.scrrect[2]*3 > s.scrrect[3]*4 {
		s.gameWidth, s.gameHeight = s.scrrect[2]*3*320/(s.scrrect[3]*4), 240
	} else {
		s.gameWidth, s.gameHeight = 320, s.scrrect[3]*4*240/(s.scrrect[2]*3)
	}
	s.widthScale = float32(s.scrrect[2]) / float32(s.gameWidth)
	s.heightScale = float32(s.scrrect[3]) / float32(s.gameHeight)
}
func (s *System) eventUpdate() bool {
	s.esc = false
	for k := range s.eventKeys {
		s.eventKeys[k] = false
	}
	glfw.PollEvents()
	s.gameEnd = s.window.ShouldClose()
	return !s.gameEnd
}
func (s *System) await(fps int) bool {
	if !s.frameSkip {
		s.window.SwapBuffers()
	}
	now := time.Now()
	diff := s.redrawWait.nextTime.Sub(now)
	wait := time.Second / time.Duration(fps)
	s.redrawWait.nextTime = s.redrawWait.nextTime.Add(wait)
	switch {
	case diff >= 0 && diff < wait+2*time.Millisecond:
		time.Sleep(diff)
		fallthrough
	case now.Sub(s.redrawWait.lastDraw) > 250*time.Millisecond:
		fallthrough
	case diff >= -17*time.Millisecond:
		s.redrawWait.lastDraw = now
		s.frameSkip = false
	default:
		if diff < -150*time.Millisecond {
			s.redrawWait.nextTime = now.Add(wait)
		}
		s.frameSkip = true
	}
	s.eventUpdate()
	if !s.frameSkip {
		gl.Viewport(0, 0, int32(s.scrrect[2]), int32(s.scrrect[3]))
		gl.Clear(gl.COLOR_BUFFER_BIT)
	}
	return !s.gameEnd
}
func (s *System) update() bool {
	if s.fileInput != nil {
		if s.anyHardButton() {
			s.await(FPS * 4)
		} else {
			s.await(FPS)
		}
		return s.fileInput.Updata()
	}
	if s.netInput != nil {
		s.await(FPS)
		return s.netInput.Updata()
	}
	return s.await(FPS)
}
func (s *System) resetRemapInput() {
	for i := range s.inputRemap {
		s.inputRemap[i] = i
	}
}
func (s *System) loaderReset() {
	s.round, s.wins, s.roundsExisted = 1, [2]int32{}, [2]int32{}
	s.loader.reset()
}
func (s *System) loadStart() {
	s.loaderReset()
	s.loader.runTread()
}
func (s *System) synchronize() error {
	if s.fileInput != nil {
		return s.fileInput.Synchronize()
	} else if s.netInput != nil {
		return s.netInput.Synchronize()
	}
	return nil
}
func (s *System) anyHardButton() bool {
	for _, kc := range s.keyConfig {
		if kc.A() || kc.B() || kc.C() || kc.X() || kc.Y() || kc.Z() {
			return true
		}
	}
	return false
}
func (s *System) anyButton() bool {
	if s.fileInput != nil {
		return s.fileInput.AnyButton()
	}
	if s.netInput != nil {
		return s.netInput.AnyButton()
	}
	return s.anyHardButton()
}
func (s *System) roundEnd() bool {
	return s.intro < -s.lifebar.ro.over_hittime
}
func (s *System) roundOver() bool {
	if s.intro < -(s.lifebar.ro.over_hittime+s.lifebar.ro.over_waittime+
		s.lifebar.ro.over_wintime) && s.tickFrame() && s.anyButton() {
		s.intro = Min(s.intro, -(s.lifebar.ro.over_hittime +
			s.lifebar.ro.over_waittime + s.lifebar.ro.over_time -
			s.lifebar.ro.start_waittime))
		s.winskipped = true
	}
	return s.intro < -(s.lifebar.ro.over_hittime + s.lifebar.ro.over_waittime +
		s.lifebar.ro.over_time)
}
func (s *System) matchOver() bool {
	return s.wins[0] >= s.matchWins[0] || s.wins[1] >= s.matchWins[1]
}
func (s *System) sf(gsf GlobalSpecialFlag) bool {
	return s.specialFlag&gsf != 0
}
func (s *System) setSF(gsf GlobalSpecialFlag) {
	s.specialFlag |= gsf
}
func (s *System) unsetSF(gsf GlobalSpecialFlag) {
	s.specialFlag &^= gsf
}
func (s *System) appendToClipboard(pn, sn int, a ...interface{}) {
	spl := s.stringPool[pn].List
	if sn >= 0 && sn < len(spl) {
		s.clipboardText[pn] = append(s.clipboardText[pn],
			strings.Split(fmt.Sprintf(spl[sn], a...), "\n")...)
	}
}
func (s *System) newCharId() int32 {
	s.nextCharId++
	return s.nextCharId - 1
}
func (s *System) resetGblEffect() {
	s.allPalFX.clear()
	s.bgPalFX.clear()
	s.envShake.clear()
	s.pause, s.pausetime = 0, 0
	s.super, s.supertime = 0, 0
	s.superanim = nil
	s.envcol_time = 0
	s.specialFlag = 0
}
func (s *System) clearPlayerIdCache() {
	for k := range s.playerIdCache {
		delete(s.playerIdCache, k)
	}
}
func (s *System) playerClear(pn int) {
	if len(s.chars[pn]) > 0 {
		helpers := s.chars[pn][1:]
		for i, h := range helpers {
			helpers[i].destroy()
			helpers[i].sounds = h.sounds[:0]
		}
		p := s.chars[pn][0]
		p.children = p.children[:0]
		p.targets = p.targets[:0]
		p.sounds = p.sounds[:0]
	}
	s.projs[pn] = s.projs[pn][:0]
	s.explods[pn] = s.explods[pn][:0]
	s.explDrawlist[pn] = s.explDrawlist[pn][:0]
	s.topexplDrawlist[pn] = s.topexplDrawlist[pn][:0]
}
func (s *System) nextRound() {
	s.resetGblEffect()
	s.lifebar.reset()
	s.finish = FT_NotYet
	s.winTeam = -1
	s.winType[0], s.winType[0] = WT_N, WT_N
	s.cam.ResetZoomdelay()
	s.clearPlayerIdCache()
	s.waitdown = s.lifebar.ro.over_hittime*s.lifebar.ro.over_waittime + 900
	s.shuttertime = 0
	s.winskipped = false
	s.intro = s.lifebar.ro.start_waittime + s.lifebar.ro.ctrl_time + 1
	s.time = s.roundTime
	s.nextCharId = s.helperMax
	if s.stage.resetbg {
		s.stage.reset()
	}
	s.cam.Update(1, 0, 0)
	for i, p := range s.chars {
		if len(p) > 0 {
			s.nextCharId = Max(s.nextCharId, p[0].id+1)
			s.playerClear(i)
			p[0].posReset()
			p[0].setCtrl(false)
			p[0].clearState()
			p[0].clear2()
			p[0].varRangeSet(0, s.cgi[i].data.intpersistindex-1, 0)
			p[0].fvarRangeSet(0, s.cgi[i].data.floatpersistindex-1, 0)
			for j := range p[0].cmd {
				p[0].cmd[j].BufReset()
			}
			if s.roundsExisted[i&1] == 0 {
				s.cgi[i].sff.palList.ResetRemap()
				if s.cgi[i].sff.header.Ver0 == 1 {
					p[0].remapPal(p[0].getPalfx(),
						[...]int32{1, 1}, [...]int32{1, s.cgi[i].drawpalno})
				}
			}
			s.cgi[i].clearPCTime()
		}
	}
	for _, p := range s.chars {
		if len(p) > 0 {
			p[0].selfState(5900, 0, 0)
		}
	}
}
func (s *System) tickFrame() bool {
	return s.oldTickCount < s.tickCount
}
func (s *System) tickNextFrame() bool {
	return int(s.tickCountF+s.nextAddTime) < s.tickCount
}
func (s *System) tickInterpola() float32 {
	if s.tickNextFrame() {
		return 1
	}
	return s.tickCountF - s.lastTick + s.lastTick
}
func (s *System) addFrameTime(t float32) bool {
	s.oldTickCount = s.tickCount
	if int(s.tickCountF) > s.tickCount {
		s.tickCount++
		return false
	}
	s.tickCountF += s.nextAddTime
	if int(s.tickCountF) > s.tickCount {
		s.tickCount++
		s.lastTick = s.tickCountF
	}
	s.oldNextAddTime = s.nextAddTime
	s.nextAddTime = t
	return true
}
func (s *System) resetFrameTime() {
	s.tickCount, s.oldTickCount, s.tickCountF, s.lastTick = 0, -1, 0, 0
	s.nextAddTime, s.oldNextAddTime = 1.0/FPS, 1.0/FPS
}
func (s *System) commandUpdate() {
	for i, p := range s.chars {
		if len(p) > 0 {
			r := p[0]
			act := true
			if s.super > 0 {
				act = r.superMovetime != 0
			} else if s.pause > 0 && r.pauseMovetime == 0 {
				act = false
			}
			if act && !r.sf(CSF_noautoturn) &&
				(r.ss.no == 0 || r.ss.no == 11 || r.ss.no == 20) {
				r.furimuki()
			}
			if r.cmd[0].Input(r.key, int32(r.facing)) {
				hp := r.hitPause()
				buftime := Btoi(hp && r.gi().ver[0] != 1)
				if s.super > 0 {
					if !act && s.super <= s.superendcmdbuftime {
						hp = true
					}
				} else if s.pause > 0 {
					if !act && s.pause <= s.pauseendcmdbuftime {
						hp = true
					}
				}
				for j := range r.cmd {
					r.cmd[j].Step(int32(r.facing), r.key < 0, hp, buftime+Btoi(hp))
				}
				if r.key < 0 {
					cc := int32(-1)
					if r.roundState() == 2 && Rand(0, s.com[i]+16) > 16 {
						cc = Rand(0, int32(len(r.cmd[r.ss.sb.playerNo].Commands))-1)
					}
					for j := range p {
						if p[j].helperIndex >= 0 {
							p[j].cpucmd = cc
						}
					}
				}
			}
		}
	}
}
func (s *System) charUpdate(cvmin, cvmax,
	highest, lowest, leftest, rightest *float32) {
	s.charList.update(cvmin, cvmax, highest, lowest, leftest, rightest)
	unimplemented()
	if s.tickNextFrame() {
		unimplemented()
		s.charList.tick()
	}
}
func (s *System) action(x, y *float32, scl float32) (leftest, rightest,
	sclmul float32) {
	s.sprites = s.sprites[:0]
	s.topSprites = s.topSprites[:0]
	s.shadows = s.shadows[:0]
	s.drawc1 = s.drawc1[:0]
	s.drawc2 = s.drawc2[:0]
	s.drawc2sp = s.drawc2sp[:0]
	s.drawwh = s.drawwh[:0]
	s.cam.Update(scl, *x, *y)
	var cvmin, cvmax, highest, lowest float32 = 0, 0, 0, 0
	leftest, rightest = *x, *x
	if s.cam.verticalfollow > 0 {
		lowest = s.cam.ScreenPos[1]
	}
	if s.tickFrame() {
		s.xmin = s.cam.ScreenPos[0] + s.cam.Offset[0] + s.screenleft
		s.xmax = s.cam.ScreenPos[0] + s.cam.Offset[0] +
			float32(s.gameWidth)/s.cam.Scale - s.screenright
		if s.xmin > s.xmax {
			s.xmin = (s.xmin + s.xmax) / 2
			s.xmax = s.xmin
		}
		s.allPalFX.step()
		s.bgPalFX.step()
		s.envShake.next()
		if s.envcol_time > 0 {
			s.envcol_time--
		}
		s.drawScale, s.zoomPos = float32(math.NaN()), [2]float32{}
		if s.super > 0 {
			s.super--
		} else if s.pause > 0 {
			s.pause--
		}
		if s.supertime < 0 {
			s.supertime = ^s.supertime
			s.super = s.supertime
		}
		if s.pausetime < 0 {
			s.pausetime = ^s.pausetime
			s.pause = s.pausetime
		}
		if s.super <= 0 && s.pause <= 0 {
			s.specialFlag = 0
		} else {
			s.unsetSF(GSF_roundnotover)
		}
		if s.superanim != nil {
			s.superanim.Action()
		}
		s.charList.action(*x, &cvmin, &cvmax,
			&highest, &lowest, &leftest, &rightest)
	} else {
		s.charUpdate(&cvmin, &cvmax, &highest, &lowest, &leftest, &rightest)
	}
	unimplemented()
	return 0, 0, 1
}
func (s *System) draw(x, y, scl float32) {
	unimplemented()
}
func (s *System) fight() (reload bool) {
	s.gameTime = 0
	var life, pow [len(s.chars)]int32
	var ivar [len(s.chars)][]int32
	var fvar [len(s.chars)][]float32
	copyVar := func(pn int) {
		life[pn] = s.chars[pn][0].life
		pow[pn] = s.chars[pn][0].power
		if len(ivar[pn]) < len(s.chars[pn][0].ivar) {
			ivar[pn] = make([]int32, len(s.chars[pn][0].ivar))
		}
		copy(ivar[pn], s.chars[pn][0].ivar[:])
		if len(fvar[pn]) < len(s.chars[pn][0].fvar) {
			fvar[pn] = make([]float32, len(s.chars[pn][0].fvar))
		}
		copy(fvar[pn], s.chars[pn][0].fvar[:])
	}
	s.debugWC = nil
	dL := lua.NewState()
	defer dL.Close()
	if len(s.debugScript) > 0 {
		if err := debugScriptInit(dL, s.debugScript); err != nil {
			println(err)
		}
	}
	debugInput := func() {
		if s.debugDraw && s.debugFont != nil {
			select {
			case cl := <-s.commandLine:
				if err := dL.DoString(cl); err != nil {
					println(err)
				}
			default:
			}
		}
	}
	put := func(y *float32, txt string) {
		tmp := s.allPalFX.time
		s.allPalFX.time = 0
		for {
			w, drawTxt := int32(0), ""
			for i, r := range txt {
				w += s.debugFont.CharWidth(r) + s.debugFont.Spacing[0]
				if w > s.scrrect[2] {
					drawTxt, txt = txt[:i], txt[i:]
					break
				}
			}
			if drawTxt == "" {
				drawTxt, txt = txt, ""
			}
			*y += float32(s.debugFont.Size[1]) / s.heightScale
			s.debugFont.DrawText(drawTxt, (320-float32(s.gameWidth))/2, *y,
				1/s.widthScale, 1/s.heightScale, 0, 1)
		}
		s.allPalFX.time = tmp
	}
	drawDebug := func() {
		if s.debugDraw && s.debugFont != nil {
			y := 240 - float32(s.gameHeight)
			if len(s.debugScript) > 0 {
				for i, p := range s.chars {
					if len(p) > 0 {
						if dL.CallByParam(lua.P{Fn: dL.GetGlobal("status"), NRet: 1,
							Protect: true}, lua.LNumber(i+1)) == nil {
							s := dL.Get(-1).(lua.LString)
							if len(s) > 0 {
								put(&y, string(s))
							}
						}
					}
				}
			}
			y = MaxF(y, 48+240-float32(s.gameHeight))
			for i, p := range s.chars {
				if len(p) > 0 {
					put(&y, s.cgi[i].def)
				}
			}
			put(&y, s.stage.def)
			if s.debugWC != nil {
				put(&y, "<P"+string(s.debugWC.playerNo+1)+":"+
					string(s.debugWC.name)+">")
			}
			for i, p := range s.chars {
				if len(p) > 0 {
					for _, s := range s.clipboardText[i] {
						put(&y, s)
					}
				}
				y += float32(s.debugFont.Size[1]) / s.heightScale
			}
		}
	}
	if err := s.synchronize(); err != nil {
		println(err)
		s.esc = true
	}
	if s.netInput != nil {
		defer s.netInput.Stop()
	}
	s.wincnt.init()
	var level [len(s.chars)]int32
	for i, p := range s.chars {
		if len(p) > 0 {
			p[0].clear2()
			level[i] = s.wincnt.getLevel(i)
			if s.powerShare[i&1] {
				pmax := Max(s.cgi[i&1].data.power, s.cgi[i].data.power)
				for j := i & 1; j < len(s.chars); j += 2 {
					if len(s.chars[j]) > 0 {
						s.chars[j][0].powerMax = pmax
					}
				}
			}
		}
	}
	minlv, maxlv := level[0], level[0]
	for i, lv := range level[1:] {
		if len(s.chars[i+1]) > 0 {
			minlv = Min(minlv, lv)
			maxlv = Max(maxlv, lv)
		}
	}
	if minlv > 0 {
		for i := range level {
			level[i] -= minlv
		}
	} else if maxlv < 0 {
		for i := range level {
			level[i] -= maxlv
		}
	}
	lvmul := math.Pow(2, 1.0/12)
	for i, p := range s.chars {
		if len(p) > 0 {
			lm := float32(p[0].gi().data.life) * s.lifeMul
			switch s.tmode[i&1] {
			case TM_Single:
				switch s.tmode[(i+1)&1] {
				case TM_Simul:
					lm *= s.team1VS2Life
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.matchWins[(i+1)&1] {
						lm = lm * float32(s.numTurns[(i+1)&1]) /
							float32(s.matchWins[(i+1)&1])
					}
				}
			case TM_Simul:
				switch s.tmode[(i+1)&1] {
				case TM_Simul:
					if s.numSimul[(i+1)&1] < s.numSimul[i&1] {
						lm = lm * float32(s.numSimul[(i+1)&1]) / float32(s.numSimul[i&1])
					}
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.numSimul[i&1]*s.matchWins[(i+1)&1] {
						lm = lm * float32(s.numTurns[(i+1)&1]) /
							float32(s.numSimul[i&1]*s.matchWins[(i+1)&1])
					}
				default:
					lm /= float32(s.numSimul[i&1])
				}
			case TM_Turns:
				switch s.tmode[(i+1)&1] {
				case TM_Single:
					if s.matchWins[i&1] < s.numTurns[i&1] {
						lm = lm * float32(s.matchWins[i&1]) / float32(s.numTurns[i&1])
					}
				case TM_Simul:
					if s.numSimul[(i+1)&1]*s.matchWins[i&1] < s.numTurns[i&1] {
						lm = lm * s.team1VS2Life *
							float32(s.numSimul[(i+1)&1]*s.matchWins[i&1]) /
							float32(s.numTurns[i&1])
					}
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.numTurns[i&1] {
						lm = lm * float32(s.numTurns[(i+1)&1]) / float32(s.numTurns[i&1])
					}
				}
			}
			foo := math.Pow(lvmul, float64(-level[i]))
			p[0].lifeMax = Max(1, int32(math.Floor(foo*float64(lm))))
			if s.roundsExisted[i&1] > 0 {
				p[0].life = Min(p[0].lifeMax, int32(math.Ceil(foo*float64(p[0].life))))
			} else if s.round == 1 || s.tmode[i&1] == TM_Turns {
				p[0].life = p[0].lifeMax
				if s.round == 1 {
					p[0].power = 0
				}
			}
			copyVar(i)
		}
	}
	if s.round == 1 {
		s.bgm.Open(s.stage.bgmusic)
	}
	s.cam.Init()
	s.screenleft = float32(s.stage.screenleft) * s.stage.localscl
	s.screenright = float32(s.stage.screenright) * s.stage.localscl
	oldWins, oldDraws := s.wins, s.draws
	var x, y, newx, newy, l, r float32
	var scl, sclmul float32
	reset := func() {
		s.wins, s.draws = oldWins, oldDraws
		for i, p := range s.chars {
			if len(p) > 0 {
				p[0].life = life[i]
				p[0].power = pow[i]
				copy(p[0].ivar[:], ivar[i])
				copy(p[0].fvar[:], fvar[i])
			}
		}
		s.resetFrameTime()
		s.nextRound()
		x, y, newx, newy, l, r, scl, sclmul = 0, 0, 0, 0, 0, 0, 1, 1
		s.cam.Update(scl, x, y)
	}
	reset()
	for !s.esc {
		s.step, s.roundResetFlg, s.reloadFlg = false, false, false
		for k, v := range s.eventKeys {
			if v {
				if scr := s.hotkeys[k]; len(scr) > 0 {
					if err := dL.DoString(scr); err != nil {
						println(err)
					}
				}
			}
		}
		if s.roundResetFlg {
			reset()
		}
		if s.reloadFlg {
			return true
		}
		if s.roundOver() {
			s.round++
			for i := range s.roundsExisted {
				s.roundsExisted[i]++
			}
			if !s.matchOver() && (s.tmode[0] != TM_Turns || s.chars[0][0].win()) &&
				(s.tmode[1] != TM_Turns || s.chars[1][0].win()) {
				for i, p := range s.chars {
					if len(p) > 0 {
						if s.tmode[i&1] != TM_Turns || !p[0].win() {
							p[0].life = p[0].lifeMax
						} else if p[0].life <= 0 {
							p[0].life = 1
						}
						copyVar(i)
					}
				}
				oldWins, oldDraws = s.wins, s.draws
				reset()
			} else {
				for i, tm := range s.tmode {
					if s.chars[i][0].win() || !s.chars[i][0].lose() && tm != TM_Turns {
						for j := i; j < len(s.chars); j += 2 {
							if len(s.chars[j]) > 0 {
								if s.chars[j][0].win() {
									s.chars[j][0].life = Max(1, int32(math.Ceil(math.Pow(lvmul,
										float64(level[i]))*float64(s.chars[j][0].life))))
								} else {
									s.chars[j][0].life = Max(1, s.cgi[j].data.life)
								}
							}
						}
					} else {
						s.chars[i][0].life = 0
					}
					break
				}
			}
		}
		if s.turbo < 1 {
			sclmul = float32(math.Pow(float64(sclmul), float64(s.turbo)))
		}
		scl = s.cam.ScaleBound(scl * sclmul)
		tmp := (float32(s.gameWidth) / 2) / scl
		if AbsF((l+r)-(newx-x)*2) >= tmp/2 {
			tmp = MaxF(0, MinF(tmp, MaxF((newx-x)-l, r-(newx-x))))
		}
		x = s.cam.XBound(scl, MinF(x+l+tmp, MaxF(x+r-tmp, newx)))
		if !s.cam.ZoomEnable {
			// Pos X の誤差が出ないように精度を落とす
			x = float32(math.Ceil(float64(x)*4-0.5) / 4)
		}
		y = s.cam.YBound(scl, newy)
		if s.tickFrame() && (s.super <= 0 || !s.superpausebg) &&
			(s.pause <= 0 || !s.pausebg) {
			s.stage.action()
		}
		newx, newy = x, y
		l, r, sclmul = s.action(&newx, &newy, scl)
		debugInput()
		if !s.addFrameTime(s.turbo) {
			if !s.eventUpdate() {
				return false
			}
			continue
		}
		if !s.frameSkip {
			dx, dy, dscl := x, y, scl
			if !math.IsNaN(float64(s.drawScale)) &&
				!math.IsNaN(float64(s.zoomPos[0])) &&
				!math.IsNaN(float64(s.zoomPos[1])) {
				dscl = MaxF(s.cam.MinScale, s.drawScale/s.cam.BaseScale())
				dx = s.cam.XBound(dscl, x+s.zoomPos[0]*(dscl-scl)/dscl)
				dy = y + s.zoomPos[1]
			}
			s.draw(dx, dy, dscl)
			drawDebug()
		}
		if !s.update() {
			break
		}
	}
	return false
}

type wincntMap map[string][]int32

func (wm *wincntMap) init() {
	if sys.autolevel {
		b, err := ioutil.ReadFile(sys.wincntFileName)
		if err != nil {
			return
		}
		str := string(b)
		if len(str) < 3 {
			return
		}
		if str[:3] == string('\ufeff') {
			str = str[3:]
		}
		toint := func(strAry []string) (intAry []int32) {
			for _, s := range strAry {
				i, _ := strconv.ParseInt(s, 10, 32)
				intAry = append(intAry, int32(i))
			}
			return
		}
		for _, l := range strings.Split(str, "\n") {
			tmp := strings.Split(l, ",")
			if len(tmp) >= 2 {
				item := toint(strings.Split(strings.TrimSpace(tmp[1]), " "))
				if len(item) < MaxPalNo {
					item = append(item, make([]int32, MaxPalNo-len(item))...)
				}
				(*wm)[tmp[0]] = item
			}
		}
	}
}
func (wm *wincntMap) getItem(def string) []int32 {
	lv, _ := (*wm)[def]
	if len(lv) < MaxPalNo {
		lv = append(lv, make([]int32, MaxPalNo-len(lv))...)
	}
	return lv
}
func (wm *wincntMap) getLevel(p int) int32 {
	return wm.getItem(sys.cgi[p].def)[sys.cgi[p].palno-1]
}

type SelectChar struct {
	def, name, sprite    string
	sportrait, lportrait *Sprite
}
type SelectStage struct {
	def, name string
}
type Select struct {
	columns, rows   int
	cellsize        [2]float32
	cellscale       [2]float32
	randomspr       *Sprite
	randomscl       [2]float32
	charlist        []SelectChar
	stagelist       []SelectStage
	curStageNo      int
	selected        [2][][2]int
	selectedStageNo int
}

func newSelect() *Select {
	return &Select{columns: 5, rows: 2, randomscl: [...]float32{1, 1},
		cellsize: [...]float32{29, 29}, cellscale: [...]float32{1, 1},
		selectedStageNo: -1}
}
func (s *Select) GetCharNo(i int) int {
	n := i
	if len(s.charlist) > 0 {
		n %= len(s.charlist)
		if n < 0 {
			n += len(s.charlist)
		}
	}
	return n
}
func (s *Select) GetChar(i int) *SelectChar {
	if len(s.charlist) == 0 {
		return nil
	}
	n := s.GetCharNo(i)
	return &s.charlist[n]
}
func (s *Select) SetStageNo(n int) int {
	s.curStageNo = n % (len(s.stagelist) + 1)
	if s.curStageNo < 0 {
		s.curStageNo += len(s.stagelist) + 1
	}
	return s.curStageNo
}
func (s *Select) SelectStage(n int) { s.selectedStageNo = n }
func (s *Select) GetStageName(n int) string {
	n %= len(s.stagelist) + 1
	if n < 0 {
		n += len(s.stagelist) + 1
	}
	if n == 0 {
		return "Random"
	}
	return s.stagelist[n-1].name
}
func (s *Select) AddCahr(def string) {
	s.charlist = append(s.charlist, SelectChar{})
	sc := &s.charlist[len(s.charlist)-1]
	def = strings.Replace(strings.TrimSpace(strings.Split(def, ",")[0]),
		"\\", "/", -1)
	if strings.ToLower(def) == "randomselect" {
		sc.def, sc.name = "randomselect", "Random"
		return
	}
	idx := strings.Index(def, "/")
	if len(def) >= 4 && strings.ToLower(def[len(def)-4:]) == ".def" {
		if idx < 0 {
			return
		}
	} else if idx < 0 {
		def += "/" + def + ".def"
	} else {
		def += ".def"
	}
	if def[0] != '/' || idx > 0 && strings.Index(def[:idx], ":") < 0 {
		def = "chars/" + def
	}
	if def = FileExist(def); len(def) == 0 {
		return
	}
	str, err := LoadText(def)
	if err != nil {
		return
	}
	sc.def = def
	lines, i, info, files, sprite := SplitAndTrim(str, "\n"), 0, true, true, ""
	for i < len(lines) {
		is, name, _ := ReadIniSection(lines, &i)
		switch name {
		case "info":
			if info {
				info = false
				var ok bool
				sc.name, ok, _ = is.getText("displayname")
				if !ok {
					sc.name, _, _ = is.getText("name")
				}
			}
		case "files":
			if files {
				files = false
				sprite = is["sprite"]
			}
		}
	}
	sc.sprite = sprite
	LoadFile(&sprite, def, func(file string) error {
		var err error
		sc.sportrait, err = LoadFromSff(file, 9000, 0)
		return err
	})
	sprite = sc.sprite
	LoadFile(&sprite, def, func(file string) error {
		var err error
		sc.lportrait, err = LoadFromSff(file, 9000, 1)
		return err
	})
}
func (s *Select) AddStage(def string) error {
	var lines []string
	if err := LoadFile(&def, "stages/", func(file string) error {
		str, err := LoadText(file)
		if err != nil {
			return err
		}
		lines = SplitAndTrim(str, "\n")
		return nil
	}); err != nil {
		return err
	}
	i, info := 0, true
	s.stagelist = append(s.stagelist, SelectStage{})
	ss := &s.stagelist[len(s.stagelist)-1]
	ss.def = def
	for i < len(lines) {
		is, name, _ := ReadIniSection(lines, &i)
		switch name {
		case "info":
			if info {
				info = false
				var ok bool
				ss.name, ok, _ = is.getText("displayname")
				if !ok {
					ss.name, ok, _ = is.getText("name")
					if !ok {
						ss.name = def
					}
				}
			}
		}
	}
	return nil
}
func (s *Select) AddSelectedChar(tn, cn, pl int) bool {
	m, n := 0, s.GetCharNo(cn)
	if len(s.charlist) == 0 || len(s.charlist[n].def) == 0 {
		return false
	}
	for s.charlist[n].def == "randomselect" || len(s.charlist[n].def) == 0 {
		m++
		if m > 100000 {
			return false
		}
		n = int(Rand(0, int32(len(s.charlist))-1))
		pl = int(Rand(1, 12))
	}
	sys.loadMutex.Lock()
	s.selected[tn] = append(s.selected[tn], [...]int{n, pl})
	sys.loadMutex.Unlock()
	return true
}
func (s *Select) ClearSelected() {
	sys.loadMutex.Lock()
	s.selected = [2][][2]int{}
	sys.loadMutex.Unlock()
	s.selectedStageNo = -1
}

type LoaderState int32

const (
	LS_NotYet LoaderState = iota
	LS_Loading
	LS_Complete
	LS_Error
	LS_Cancel
)

type Loader struct {
	state    LoaderState
	loadExit chan LoaderState
	err      error
}

func newLoader() *Loader {
	return &Loader{state: LS_NotYet, loadExit: make(chan LoaderState, 1)}
}
func (l *Loader) loadChar(pn int) int {
	sys.loadMutex.Lock()
	result := -1
	nsel := len(sys.sel.selected[pn&1])
	if sys.tmode[pn&1] == TM_Simul {
		if pn>>1 >= int(sys.numSimul[pn&1]) {
			sys.cgi[pn].states = nil
			sys.chars[pn] = nil
			result = 1
		}
	} else if pn >= 2 {
		result = 0
	}
	if sys.tmode[pn&1] == TM_Turns && nsel < int(sys.numTurns[pn&1]) {
		result = 0
	}
	memberNo := pn >> 1
	if sys.tmode[pn&1] == TM_Turns {
		memberNo = int(sys.wins[^pn&1])
	}
	if nsel <= memberNo {
		result = 0
	}
	if result >= 0 {
		sys.loadMutex.Unlock()
		return result
	}
	pal, idx := int32(sys.sel.selected[pn&1][memberNo][1]), make([]int, nsel)
	for i := range idx {
		idx[i] = sys.sel.selected[pn&1][i][0]
	}
	sys.loadMutex.Unlock()
	cdef := sys.sel.charlist[idx[memberNo]].def
	var p *Char
	if len(sys.chars) > 0 && cdef == sys.cgi[pn].def {
		p = sys.chars[pn][0]
		p.key = pn
		if sys.com[pn] != 0 {
			p.key ^= -1
		}
	} else {
		p = newChar(pn, 0)
		sys.cgi[pn].sff = nil
	}
	sys.chars[pn] = make([]*Char, 1)
	sys.chars[pn][0] = p
	if sys.roundsExisted[pn&1] == 0 {
		sys.cgi[pn].palno = sys.cgi[pn].palkeymap[pal-1] + 1
	}
	if sys.cgi[pn].sff == nil {
		if sys.cgi[pn].states, l.err =
			newCompiler().Compile(p.playerNo, cdef); l.err != nil {
			sys.chars[pn] = nil
			return -1
		}
		if l.err = p.load(cdef); l.err != nil {
			sys.chars[pn] = nil
			return -1
		}
	}
	if pn < len(sys.lifebar.fa[sys.tmode[pn&1]]) {
		fa := sys.lifebar.fa[sys.tmode[pn&1]][pn]
		fa.face = sys.cgi[pn].sff.GetOwnPalSprite(
			int16(fa.face_spr[0]), int16(fa.face_spr[1]))
		if sys.tmode[pn&1] == TM_Turns && sys.round == 1 {
			fa.numko = 0
			fa.teammate_face = make([]*Sprite, nsel)
			for i, ci := range idx {
				sprite := sys.sel.charlist[ci].sprite
				LoadFile(&sprite, sys.sel.charlist[ci].def, func(file string) error {
					var err error
					fa.teammate_face[i], err = LoadFromSff(file,
						int16(fa.teammate_face_spr[0]), int16(fa.teammate_face_spr[1]))
					return err
				})
			}
		}
	}
	return 1
}
func (l *Loader) loadStage() bool {
	var def string
	if sys.sel.selectedStageNo == 0 {
		def = sys.sel.stagelist[Rand(0, int32(len(sys.sel.stagelist))-1)].def
	} else {
		def = sys.sel.stagelist[sys.sel.selectedStageNo-1].def
	}
	if sys.stage != nil && sys.stage.def == def {
		return true
	}
	sys.stage, l.err = LoadStage(def)
	return l.err == nil
}
func (l *Loader) load() {
	defer func() { l.loadExit <- l.state }()
	charDone, stageDone := make([]bool, len(sys.chars)), false
	allCharDone := func() bool {
		for _, b := range charDone {
			if !b {
				return false
			}
		}
		return true
	}
	for !stageDone || !allCharDone() {
		runtime.LockOSThread()
		for i, b := range charDone {
			if !b {
				result := l.loadChar(i)
				if result > 0 {
					charDone[i] = true
				} else if result < 0 {
					l.state = LS_Error
					return
				}
			}
		}
		for i := 0; i < 2; i++ {
			if !charDone[i+2] && len(sys.sel.selected[i]) > 0 &&
				sys.tmode[i] != TM_Simul {
				for j := i + 2; j < len(sys.chars); j += 2 {
					sys.chars[j], sys.cgi[j].states, charDone[j] = nil, nil, true
					sys.cgi[j].wakewakaLength = 0
				}
			}
		}
		if !stageDone && sys.sel.selectedStageNo >= 0 {
			if !l.loadStage() {
				l.state = LS_Error
				return
			}
			stageDone = true
		}
		runtime.UnlockOSThread()
		time.Sleep(10 * time.Millisecond)
		if sys.gameEnd {
			l.state = LS_Cancel
		}
		if l.state == LS_Cancel {
			return
		}
	}
	l.state = LS_Complete
}
func (l *Loader) reset() {
	if l.state != LS_NotYet {
		l.state = LS_Cancel
		<-l.loadExit
		l.state = LS_NotYet
	}
	l.err = nil
	for i := range sys.cgi {
		if sys.roundsExisted[i&1] == 0 {
			sys.cgi[i].drawpalno = -1
		}
	}
}
func (l *Loader) runTread() bool {
	if l.state != LS_NotYet {
		return false
	}
	l.state = LS_Loading
	go l.load()
	return true
}
