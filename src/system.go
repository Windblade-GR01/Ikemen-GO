package main

import (
	"bufio"
	"fmt"
	"image"
	"io"
	"io/ioutil"
	"log"
	"math"
	"os"
	"runtime"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/faiface/beep"
	"github.com/faiface/beep/speaker"
	"github.com/go-gl/gl/v2.1/gl"
	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/timshannon/go-openal/openal"
	lua "github.com/yuin/gopher-lua"
)

const (
	MaxSimul        = 32
	MaxAttachedChar = 2
	FPS             = 60
	P1P3Dist        = 25
	Mp3SampleRate   = 44100
)

type TeamMode int32

const (
	TM_Single TeamMode = iota
	TM_Simul
	TM_Turns
	TM_Tag
	TM_LAST = TM_Tag
)

// System struct, holds most of the data that is accessed globally through the program.
type System struct {
	randseed                int32
	scrrect                 [4]int32
	gameWidth, gameHeight   int32
	widthScale, heightScale float32
	window                  *Window
	gameEnd, frameSkip      bool
	redrawWait              struct{ nextTime, lastDraw time.Time }
	brightness              int32
	roundTime               int32
	lifeMul                 float32
	singleVsTeamLife        float32
	turnsRecoveryBase       float32
	turnsRecoveryBonus      float32
	lifebarFontScale        float32
	debugFont               *Fnt
	debugDraw               bool
	debugRef                [2]int
	mixer                   Mixer
	bgm                     Bgm
	audioContext            *openal.Context
	nullSndBuf              [audioOutLen * 2]int16
	sounds                  Sounds
	allPalFX, bgPalFX       PalFX
	lifebar                 Lifebar
	sel                     Select
	keyState                map[glfw.Key]bool
	netInput                *NetInput
	fileInput               *FileInput
	aiInput                 [MaxSimul*2 + MaxAttachedChar]AiInput
	keyConfig               []KeyConfig
	joystickConfig          []KeyConfig
	com                     [MaxSimul*2 + MaxAttachedChar]float32
	autolevel               bool
	home                    int
	gameTime                int32
	match                   int32
	inputRemap              [MaxSimul*2 + MaxAttachedChar]int
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
	chars                   [MaxSimul*2 + MaxAttachedChar][]*Char
	charList                CharList
	cgi                     [MaxSimul*2 + MaxAttachedChar]CharGlobalInfo
	tmode                   [2]TeamMode
	numSimul, numTurns      [2]int32
	esc                     bool
	loadMutex               sync.Mutex
	ignoreMostErrors        bool
	stringPool              [MaxSimul*2 + MaxAttachedChar]StringPool
	bcStack, bcVarStack     BytecodeStack
	bcVar                   []BytecodeValue
	workingChar             *Char
	workingState            *StateBytecode
	specialFlag             GlobalSpecialFlag
	afterImageMax           int32
	comboExtraFrameWindow   int32
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
	envcol                  [3]int32
	envcol_time             int32
	envcol_under            bool
	stage                   *Stage
	stageList               map[int32]*Stage
	stageLoop               bool
	stageLoopNo             int
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
	paused, step            bool
	roundResetFlg           bool
	reloadFlg               bool
	reloadCharSlot          [MaxSimul*2 + MaxAttachedChar]bool
	shortcutScripts         map[ShortcutKey]*ShortcutScript
	turbo                   float32
	commandLine             chan string
	drawScale               float32
	zoomlag                 float32
	zoomScale               float32
	zoomPosXLag             float32
	zoomPosYLag             float32
	enableZoomstate         bool
	zoomPos                 [2]float32
	debugWC                 *Char
	cam                     Camera
	finish                  FinishType
	waitdown                int32
	slowtime                int32
	shuttertime             int32
	fadeintime              int32
	fadeouttime             int32
	projs                   [MaxSimul*2 + MaxAttachedChar][]Projectile
	explods                 [MaxSimul*2 + MaxAttachedChar][]Explod
	explDrawlist            [MaxSimul*2 + MaxAttachedChar][]int
	topexplDrawlist         [MaxSimul*2 + MaxAttachedChar][]int
	changeStateNest         int32
	sprites                 DrawList
	topSprites              DrawList
	shadows                 ShadowList
	drawc1                  ClsnRect
	drawc2                  ClsnRect
	drawc2sp                ClsnRect
	drawc2mtk               ClsnRect
	drawwh                  ClsnRect
	autoguard               [MaxSimul*2 + MaxAttachedChar]bool
	accel                   float32
	clsnSpr                 Sprite
	clsnDraw                bool
	statusDraw              bool
	mainThreadTask          chan func()
	explodMax               int
	workpal                 []uint32
	playerProjectileMax     int
	errLog                  *log.Logger
	audioClose              chan bool
	nomusic                 bool
	workBe                  []BytecodeExp
	lifeAdjustment          bool
	loseSimul               bool
	loseTag                 bool
	fullscreen              bool
	allowDebugKeys          bool
	commonAir               string
	commonCmd               string
	keyInput                glfw.Key
	keyString               string
	timerCount              []int32
	cmdFlags                map[string]string
	masterVolume            int
	wavVolume               int
	bgmVolume               int
	audioDucking            bool
	windowTitle             string
	screenshotFolder        string
	//FLAC_FrameWait          int

	controllerStickSensitivity float32
	xinputTriggerSensitivity   float32

	// Localcoord sceenpack
	luaLocalcoord    [2]int32
	luaSpriteScale   float64
	luaPortraitScale float32
	luaSpriteOffsetX float64

	// Localcoord lifebar
	lifebarScale         float32
	lifebarOffsetX       float32
	lifebarPortraitScale float32
	lifebarLocalcoord    [2]int32

	// Shader Vars
	postProcessingShader    int32
	multisampleAntialiasing bool
	fontShaderVer           string

	// External Shader Vars
	externalShaderList  []string
	externalShaderNames []string
	externalShaders     [][]string

	// Icon
	windowMainIcon         []image.Image
	windowMainIconLocation []string

	// Rendering
	borderless bool
	vRetrace   int

	gameMode        string
	demoTime        int32
	frameCounter    int32
	motifDir        string
	captureNum      int
	challenger      int
	roundType       [2]RoundType
	ocd             [MaxSimul*2 + MaxAttachedChar]OverrideCharData
	ratioLevel      [MaxSimul*2 + MaxAttachedChar]int32
	timerStart      int32
	timerRounds     []int32
	scoreStart      [2]float32
	scoreRounds     [][2]float32
	matchData       *lua.LTable
	consecutiveWins [2]int32
	commonConst     string
	commonLua       []string
	commonStates    []string
	gameSpeed       float32
	maxPowerMode    bool
	clsnText        []ClsnText
	consoleText     []string
	consoleType     int
	luaLState       *lua.LState
	statusLFunc     *lua.LFunction
	listLFunc       []*lua.LFunction
	endMatch        bool
	postMatchFlg    bool
	legacyMode      bool
}

// sys
// The only instance of a System struct.
// Do not create more than 1.
var sys System = System{
	randseed:           int32(time.Now().UnixNano()),
	scrrect:            [...]int32{0, 0, 320, 240},
	gameWidth:          320,
	gameHeight:         240,
	widthScale:         1,
	heightScale:        1,
	brightness:         256,
	roundTime:          -1,
	lifeMul:            1,
	singleVsTeamLife:   1,
	turnsRecoveryBase:  0.125,
	turnsRecoveryBonus: 0.275,
	mixer:              *newMixer(),
	bgm:                *newBgm(),
	sounds:             newSounds(16),
	allPalFX:           *newPalFX(),
	bgPalFX:            *newPalFX(),
	sel:                *newSelect(),
	keyState:           make(map[glfw.Key]bool),
	match:              1,
	listenPort:         "7500",
	loader:             *newLoader(),
	numSimul:           [...]int32{2, 2}, numTurns: [...]int32{2, 2},
	ignoreMostErrors:      true,
	superpmap:             *newPalFX(),
	stageList:             make(map[int32]*Stage),
	wincnt:                wincntMap(make(map[string][]int32)),
	wincntFileName:        "save/autolevel.save",
	powerShare:            [...]bool{true, true},
	oldNextAddTime:        1,
	commandLine:           make(chan string),
	cam:                   *newCamera(),
	statusDraw:            true,
	mainThreadTask:        make(chan func(), 65536),
	workpal:               make([]uint32, 256),
	errLog:                log.New(os.Stderr, "", 0),
	audioClose:            make(chan bool, 1),
	keyInput:              glfw.KeyUnknown,
	comboExtraFrameWindow: 1,
	fontShaderVer:         "150 core",
	//FLAC_FrameWait:          -1,
	luaSpriteScale:       1,
	luaPortraitScale:     1,
	lifebarScale:         1,
	lifebarPortraitScale: 1,
	vRetrace:             1,
	consoleType:          1,
}

type Window struct {
	*glfw.Window
	title      string
	fullscreen bool
	x, y, w, h int
}

var firstWindow = true

func (s *System) newWindow(title string, fullscreen bool, w, h int, oldWindow *Window) (*Window, error) {
	var err error
	var window, oldW *glfw.Window
	var x, y int

	if oldWindow != nil {
		oldW = oldWindow.Window
		x, y = oldW.GetPos()
	}

	if fullscreen {
		window, err = s.fullscreenWindow(w, h, title, nil, nil, oldW)
		window.SetInputMode(glfw.CursorMode, glfw.CursorHidden)
	} else {
		window, err = glfw.CreateWindow(w, h, title, nil, oldW)
		window.SetInputMode(glfw.CursorMode, glfw.CursorNormal)
	}
	chk(err)
	if firstWindow {
		x, y = window.GetPos()
		window.MakeContextCurrent()
		window.SetKeyCallback(keyCallback)
		window.SetCharModsCallback(charCallback)
		// V-Sync
		if s.vRetrace != -1 {
			glfw.SwapInterval(s.vRetrace)
		}
		// Initialize OpenGL.
		chk(gl.Init())
		firstWindow = false
	}
	ret := &Window{window, title, fullscreen, x, y, w, h}
	return ret, err
}
func (s *System) fullscreenWindow(w, h int, title string, monitor *glfw.Monitor,
	mode *glfw.VidMode, oldWindow *glfw.Window) (*glfw.Window, error) {
	var err error
	var window *glfw.Window

	if monitor == nil {
		if monitor = glfw.GetPrimaryMonitor(); monitor == nil {
			return nil, fmt.Errorf("failed to obtain primary monitor")
		}
	}
	//if mode == nil {
	//	if mode = monitor.GetVideoMode(); mode == nil {
	//		return nil, fmt.Errorf("failed to obtain video mode")
	//	}
	//}
	if runtime.GOOS == "windows" && s.borderless {
		window, err = glfw.CreateWindow(w, h, title, nil, oldWindow)
		window.SetAttrib(glfw.Decorated, 0)
		window.SetPos(0, 0)
		window.SetSize(w, h)
	} else {
		//window, err = glfw.CreateWindow(mode.Width, mode.Height, title, monitor, oldWindow)
		window, err = glfw.CreateWindow(w, h, title, monitor, oldWindow)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to create window: %w", err)
	}
	return window, nil
}

// Unused.
// TODO: Check on what this was used.
//func (w *Window) destroy() {
//	w.Window.Destroy()
//}
func (w *Window) toggleFullscreen() {
	if w.fullscreen {
		w.SetMonitor(nil, w.x, w.y, w.w, w.h, 60)
		w.SetInputMode(glfw.CursorMode, glfw.CursorNormal)
	} else {
		w.SetMonitor(glfw.GetPrimaryMonitor(), w.x, w.y, w.w, w.h, 60)
		w.SetInputMode(glfw.CursorMode, glfw.CursorHidden)
	}
	w.fullscreen = !w.fullscreen
}

type OverrideCharData struct {
	life        int32
	lifeMax     int32
	power       int32
	dizzyPoints int32
	guardPoints int32
	lifeRatio   float32
	attackRatio float32
}

func (s *System) resetOverrideCharData() {
	for i := range s.ocd {
		s.ocd[i] = OverrideCharData{life: 0, lifeMax: 0, power: 0,
			dizzyPoints: 0, guardPoints: 0, lifeRatio: 1.0, attackRatio: 1.0}
	}
}

// Initialize stuff, this is called after the config int at main.go
func (s *System) init(w, h int32) *lua.LState {
	s.setWindowSize(w, h)
	var err error
	// Create a GLWF window.
	glfw.WindowHint(glfw.Resizable, glfw.False)
	glfw.WindowHint(glfw.ContextVersionMajor, 2)
	glfw.WindowHint(glfw.ContextVersionMinor, 1)

	s.window, err = sys.newWindow(s.windowTitle, s.fullscreen, int(s.scrrect[2]), int(s.scrrect[3]), nil)

	// Check if the shader selected is currently avalible.
	if s.postProcessingShader < int32(len(s.externalShaderList))+3 {
		s.postProcessingShader = 0
	}

	// Loading of external shader data.
	// We need to do this before the render initialization at "RenderInit()"
	if len(s.externalShaderList) > 0 {
		// First we initialize arrays.
		s.externalShaders = make([][]string, 2)
		s.externalShaderNames = make([]string, len(s.externalShaderList))
		s.externalShaders[0] = make([]string, len(s.externalShaderList))
		s.externalShaders[1] = make([]string, len(s.externalShaderList))

		// Then we load.
		for i, shaderLocation := range s.externalShaderList {
			// Create names.
			shaderLocation = strings.Replace(shaderLocation, "\\", "/", -1)
			splitDir := strings.Split(shaderLocation, "/")
			s.externalShaderNames[i] = splitDir[len(splitDir)-1]

			// Load vert shaders.
			content, err := ioutil.ReadFile(shaderLocation + ".vert")
			if err != nil {
				chk(err)
			}
			s.externalShaders[0][i] = string(content) + "\x00"

			// Load frag shaders.
			content, err = ioutil.ReadFile(shaderLocation + ".frag")
			if err != nil {
				chk(err)
			}
			s.externalShaders[1][i] = string(content) + "\x00"
		}
	}
	// PS: The "\x00" is what is know as Null Terminator.

	// Now we proceed to int the render.
	RenderInit()
	// And the audio.
	s.audioOpen()
	sr := beep.SampleRate(Mp3SampleRate)
	speaker.Init(sr, sr.N(time.Second/10))
	l := lua.NewState()
	l.Options.IncludeGoStackTrace = true
	l.OpenLibs()
	for i := range s.inputRemap {
		s.inputRemap[i] = i
	}
	for i := range s.stringPool {
		s.stringPool[i] = *NewStringPool()
	}
	s.clsnSpr = *newSprite()
	s.clsnSpr.Size, s.clsnSpr.Pal = [...]uint16{1, 1}, make([]uint32, 256)
	s.clsnSpr.SetPxl([]byte{0})
	s.resetOverrideCharData()
	systemScriptInit(l)
	s.shortcutScripts = make(map[ShortcutKey]*ShortcutScript)
	// So now that we have a window we add a icon.
	if len(s.windowMainIconLocation) > 0 {
		// First we initialize arrays.
		f := make([]io.ReadCloser, len(s.windowMainIconLocation))
		s.windowMainIcon = make([]image.Image, len(s.windowMainIconLocation))
		// And then we load them.
		for i, iconLocation := range s.windowMainIconLocation {
			f[i], _ = os.Open(iconLocation)
			s.windowMainIcon[i], _, err = image.Decode(f[i])
		}
		s.window.Window.SetIcon(s.windowMainIcon)
		chk(err)
	}
	// [Icon add end]

	// Error print?
	go func() {
		stdin := bufio.NewScanner(os.Stdin)
		for stdin.Scan() {
			if err := stdin.Err(); err != nil {
				s.errLog.Println(err.Error())
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
	for _, v := range s.shortcutScripts {
		v.Activate = false
	}
	glfw.PollEvents()
	s.gameEnd = s.window.Window.ShouldClose()
	return !s.gameEnd
}
func (s *System) runMainThreadTask() {
	for {
		select {
		case f := <-s.mainThreadTask:
			f()
		default:
			return
		}
	}
}
func (s *System) await(fps int) bool {
	if !s.frameSkip {
		// Render the finished frame
		unbindFB()
		s.window.Window.SwapBuffers()
		// Begin the next frame
		bindFB()
	}
	s.runMainThreadTask()
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
		gl.Viewport(0, 0, s.scrrect[2], s.scrrect[3])
		if s.netInput == nil {
			gl.Clear(gl.COLOR_BUFFER_BIT)
		}
	}
	return !s.gameEnd
}
func (s *System) update() bool {
	s.frameCounter++
	if s.fileInput != nil {
		if s.anyHardButton() {
			s.await(FPS * 4)
		} else {
			s.await(FPS)
		}
		return s.fileInput.Update()
	}
	if s.netInput != nil {
		s.await(FPS)
		return s.netInput.Update()
	}
	return s.await(FPS)
}
func (s *System) audioOpen() {
	if s.audioContext == nil {
		device := openal.OpenDevice("")
		if device == nil {
			chk(openal.Err())
		}
		s.audioContext = device.CreateContext()
		if err := device.Err(); err != nil {
			s.errLog.Println(err.Error())
		}
		s.audioContext.Activate()
		go s.soundWrite()
	}
}
func (s *System) soundWrite() {
	defer func() { s.audioClose <- true }()
	src := NewAudioSource()
	processed := false
	for !s.gameEnd {
		if src.Src.State() != openal.Playing {
			src.Src.Play()
		}
		if !processed {
			time.Sleep(10 * time.Millisecond)
		}
		processed = false
		if src.Src.BuffersProcessed() > 0 {
			var out []int16
			select {
			case out = <-s.mixer.out:
			default:
				out = s.nullSndBuf[:]
			}
			buf := src.Src.UnqueueBuffer()
			buf.SetDataInt16(openal.FormatStereo16, out, audioFrequency)
			src.Src.QueueBuffer(buf)
			if err := openal.Err(); err != nil {
				s.errLog.Println(err.Error())
			}
			processed = true
		}
		if !s.nomusic {
			if s.bgm.ctrl != nil && s.bgm.streamer != nil {
				s.bgm.ctrl.Paused = false
				if s.bgm.bgmLoopEnd > 0 && s.bgm.streamer.Position() >= s.bgm.bgmLoopEnd {
					speaker.Lock()
					s.bgm.streamer.Seek(s.bgm.bgmLoopStart)
					speaker.Unlock()
				}
			}
		} else {
			if s.bgm.ctrl != nil {
				s.bgm.Pause()
			}
		}

		//if s.FLAC_FrameWait >= 0 {
		//	if s.FLAC_FrameWait == 0 {
		//		s.bgm.PlayMemAudio(s.bgm.loop, s.bgm.bgmVolume)
		//	}
		//	s.FLAC_FrameWait--
		//}
	}
	src.Delete()
	openal.NullContext.Activate()
	device := s.audioContext.GetDevice()
	s.audioContext.Destroy()
	s.audioContext = nil
	device.CloseDevice()
}
func (s *System) playSound() {
	if s.mixer.write() {
		s.sounds.mixSounds()
		for _, ch := range s.chars {
			for _, c := range ch {
				c.sounds.mixSounds()
			}
		}
	}
}
func (s *System) resetRemapInput() {
	for i := range s.inputRemap {
		s.inputRemap[i] = i
	}
}
func (s *System) loaderReset() {
	s.round, s.wins, s.roundsExisted, s.roundType, s.challenger = 1, [2]int32{}, [2]int32{}, [2]RoundType{}, 0
	s.loader.reset()
}
func (s *System) loadStart() {
	s.loaderReset()
	s.loader.runTread()
}
func (s *System) synchronize() error {
	if s.fileInput != nil {
		s.fileInput.Synchronize()
	} else if s.netInput != nil {
		return s.netInput.Synchronize()
	}
	return nil
}
func (s *System) anyHardButton() bool {
	for _, kc := range s.keyConfig {
		if kc.a() || kc.b() || kc.c() || kc.x() || kc.y() || kc.z() {
			return true
		}
	}
	for _, kc := range s.joystickConfig {
		if kc.a() || kc.b() || kc.c() || kc.x() || kc.y() || kc.z() {
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
func (s *System) playerID(id int32) *Char {
	return s.charList.get(id)
}
func (s *System) matchOver() bool {
	return s.wins[0] >= s.matchWins[0] || s.wins[1] >= s.matchWins[1]
}
func (s *System) playerIDExist(id BytecodeValue) BytecodeValue {
	if id.IsSF() {
		return BytecodeSF()
	}
	return BytecodeBool(s.playerID(id.ToI()) != nil)
}
func (s *System) screenHeight() float32 {
	return 240
}
func (s *System) screenWidth() float32 {
	return float32(s.gameWidth)
}
func (s *System) roundEnd() bool {
	return s.intro < -s.lifebar.ro.over_hittime
}
func (s *System) roundOver() bool {
	if s.intro < -(s.lifebar.ro.over_hittime+s.lifebar.ro.over_waittime+
		s.lifebar.ro.over_wintime) && s.tickFrame() && (s.anyButton() && !s.sf(GSF_roundnotskip)) {
		s.intro = Min(s.intro, -(s.lifebar.ro.over_hittime +
			s.lifebar.ro.over_waittime + s.lifebar.ro.over_time -
			s.lifebar.ro.start_waittime))
		s.winskipped = true
	}
	return s.intro < -(s.lifebar.ro.over_hittime + s.lifebar.ro.over_waittime +
		s.lifebar.ro.over_time)
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
func (s *System) appendToConsole(str string) {
	s.consoleText = append(s.consoleText, str)
	if len(s.consoleText) > 15 {
		s.consoleText = s.consoleText[len(s.consoleText)-15:]
	}
}
func (s *System) printToConsole(pn, sn int, a ...interface{}) {
	spl := s.stringPool[pn].List
	if sn >= 0 && sn < len(spl) {
		for _, str := range strings.Split(OldSprintf(spl[sn], a...), "\n") {
			fmt.Printf("%s\n", str)
			s.appendToConsole(str)
		}
	}
}
func (s *System) warnConsole(str string) {
	if s.consoleType == 1 {
		s.appendToConsole(str)
		return
	}
	if s.consoleType == 2 {
		fmt.Printf("%s\n", str)
		return
	}
	if s.consoleType == 3 {
		s.appendToConsole(str)
		fmt.Printf("%s\n", str)
	}
}
func (s *System) loadTime(start time.Time, str string, shell, console bool) {
	elapsed := time.Since(start)
	str = fmt.Sprintf("%v; Load time: %v", str, elapsed)
	if shell {
		fmt.Printf("%s\n", str)
	}
	if console {
		s.appendToConsole(str)
	}
}
func (s *System) clsnHantei(clsn1 []float32, scl1, pos1 [2]float32,
	facing1 float32, clsn2 []float32, scl2, pos2 [2]float32,
	facing2 float32) bool {
	if scl1[0] < 0 {
		facing1 *= -1
		scl1[0] *= -1
	}
	if scl2[0] < 0 {
		facing2 *= -1
		scl2[0] *= -1
	}
	for i1 := 0; i1+3 < len(clsn1); i1 += 4 {
		for i2 := 0; i2+3 < len(clsn2); i2 += 4 {
			var l1, r1, l2, r2 float32
			if facing1 > 0 {
				l1, r1 = clsn1[i1], clsn1[i1+2]+1
			} else {
				l1, r1 = -clsn1[i1+2], -clsn1[i1]+1
			}
			if facing2 > 0 {
				l2, r2 = clsn2[i2], clsn2[i2+2]+1
			} else {
				l2, r2 = -clsn2[i2+2], -clsn2[i2]+1
			}
			if l1*scl1[0]+pos1[0] < r2*scl2[0]+pos2[0] &&
				l2*scl2[0]+pos2[0] < r1*scl1[0]+pos1[0] &&
				clsn1[i1+1]*scl1[1]+pos1[1] < (clsn2[i2+3]+1)*scl2[1]+pos2[1] &&
				clsn2[i2+1]*scl2[1]+pos2[1] < (clsn1[i1+3]+1)*scl1[1]+pos1[1] {
				return true
			}
		}
	}
	return false
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
func (s *System) stopAllSound() {
	for _, p := range s.chars {
		for _, c := range p {
			c.sounds = c.sounds[:0]
		}
	}
}
func (s *System) playerClear(pn int) {
	if len(s.chars[pn]) > 0 {
		for _, h := range s.chars[pn][1:] {
			h.destroy()
			h.sounds = h.sounds[:0]
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
	s.winType = [...]WinType{WT_N, WT_N}
	s.waitdown = s.lifebar.ro.over_hittime*s.lifebar.ro.over_waittime + 900
	s.slowtime = s.lifebar.ro.slow_time
	s.shuttertime = 0
	s.fadeintime = s.lifebar.ro.fadein_time
	s.fadeouttime = s.lifebar.ro.fadeout_time
	s.winskipped = false
	s.intro = s.lifebar.ro.start_waittime + s.lifebar.ro.ctrl_time + 1
	s.time = s.roundTime
	s.nextCharId = s.helperMax
	if (s.tmode[0] == TM_Turns && s.wins[1] == s.numTurns[0]-1) ||
		(s.tmode[0] != TM_Turns && s.wins[1] == s.lifebar.ro.match_wins-1) {
		s.roundType[0] = RT_Deciding
	}
	if (s.tmode[1] == TM_Turns && s.wins[0] == s.numTurns[1]-1) ||
		(s.tmode[1] != TM_Turns && s.wins[0] == s.lifebar.ro.match_wins-1) {
		s.roundType[1] = RT_Deciding
	}
	if s.roundType[0] == RT_Deciding && s.roundType[1] == RT_Deciding {
		s.roundType = [2]RoundType{RT_Final, RT_Final}
	}
	roundRef := s.round
	if s.round > 1 && len(s.stageList) > 0 && s.stageLoop {
		s.stageLoopNo++
		if s.stageLoopNo >= len(s.stageList) {
			s.stageLoopNo = 0
		}
		keys := make([]int, 0)
		for k := range s.stageList {
			keys = append(keys, int(k))
		}
		sort.Ints(keys)
		roundRef = int32(keys[s.stageLoopNo])
	}
	if _, ok := s.stageList[roundRef]; ok {
		s.stage = s.stageList[roundRef]
		s.cam.stageCamera = s.stage.stageCamera
		s.cam.Init()
		s.screenleft = float32(s.stage.screenleft) * s.stage.localscl
		s.screenright = float32(s.stage.screenright) * s.stage.localscl
		s.stage.reset()
	} else if s.stage.resetbg {
		s.stage.reset()
	}
	s.cam.ResetZoomdelay()
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
			s.cgi[i].unhittable = 0
		}
	}
	for _, p := range s.chars {
		if len(p) > 0 {
			p[0].selfState(5900, 0, -1, 0, false)
		}
	}
}
func (s *System) debugPaused() bool {
	return s.paused && !s.step && s.oldTickCount < s.tickCount
}
func (s *System) tickFrame() bool {
	return (!s.paused || s.step) && s.oldTickCount < s.tickCount
}
func (s *System) tickNextFrame() bool {
	return int(s.tickCountF+s.nextAddTime) > s.tickCount &&
		(!s.paused || s.step || s.oldTickCount >= s.tickCount)
}
func (s *System) tickInterpola() float32 {
	if s.tickNextFrame() {
		return 1
	}
	return s.tickCountF - s.lastTick + s.nextAddTime
}
func (s *System) addFrameTime(t float32) bool {
	if s.debugPaused() {
		s.oldNextAddTime = 0
		return true
	}
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
	s.nextAddTime, s.oldNextAddTime = 1, 1
}
func (s *System) commandUpdate() {
	for i, p := range s.chars {
		if len(p) > 0 {
			r := p[0]
			if r.ctrlOver() {
				for j := range r.cmd {
					r.cmd[j].BufReset()
				}
				continue
			}
			act := true
			if s.super > 0 {
				act = r.superMovetime != 0
			} else if s.pause > 0 && r.pauseMovetime == 0 {
				act = false
			}
			if act && !r.sf(CSF_noautoturn) &&
				(r.ss.no == 0 || r.ss.no == 11 || r.ss.no == 20) {
				r.turn()
			}
			for _, c := range p {
				if (c.helperIndex == 0 ||
					c.helperIndex > 0 && &c.cmd[0] != &r.cmd[0]) &&
					c.cmd[0].Input(c.key, int32(c.facing), sys.com[i]) {
					hp := c.hitPause()
					buftime := Btoi(hp && c.gi().ver[0] != 1)
					if s.super > 0 {
						if !act && s.super <= s.superendcmdbuftime {
							hp = true
						}
					} else if s.pause > 0 {
						if !act && s.pause <= s.pauseendcmdbuftime {
							hp = true
						}
					}
					for j := range c.cmd {
						c.cmd[j].Step(int32(c.facing), c.key < 0, hp, buftime+Btoi(hp))
					}
				}
			}
			if r.key < 0 {
				cc := int32(-1)
				// AI Scaling
				// TODO: Balance AI Scaling
				if r.roundState() == 2 && RandF32(0, sys.com[i]/2+32) > 32 {
					cc = Rand(0, int32(len(r.cmd[r.ss.sb.playerNo].Commands))-1)
				} else {
					cc = -1
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
func (s *System) charUpdate(cvmin, cvmax,
	highest, lowest, leftest, rightest *float32) {
	s.charList.update(cvmin, cvmax, highest, lowest, leftest, rightest)
	for i, pr := range s.projs {
		for j, p := range pr {
			if p.id >= 0 {
				s.projs[i][j].update(i)
			}
		}
	}
	if s.tickNextFrame() {
		for i, pr := range s.projs {
			for j, p := range pr {
				if p.id >= 0 {
					s.projs[i][j].clsn(i)
				}
			}
		}
		s.charList.getHit()
		for i, pr := range s.projs {
			for j, p := range pr {
				if p.id != IErr {
					s.projs[i][j].tick(i)
				}
			}
		}
		s.charList.tick()
	}
}
func (s *System) action(x, y *float32, scl float32) (leftest, rightest,
	sclMul float32) {
	s.sprites = s.sprites[:0]
	s.topSprites = s.topSprites[:0]
	s.shadows = s.shadows[:0]
	s.drawc1 = s.drawc1[:0]
	s.drawc2 = s.drawc2[:0]
	s.drawc2sp = s.drawc2sp[:0]
	s.drawc2mtk = s.drawc2mtk[:0]
	s.drawwh = s.drawwh[:0]
	s.clsnText = nil
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
		s.enableZoomstate = false
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
			s.unsetSF(GSF_roundnotskip)
		}
		if s.superanim != nil {
			s.superanim.Action()
		}
		s.charList.action(*x, &cvmin, &cvmax,
			&highest, &lowest, &leftest, &rightest)
		s.nomusic = s.sf(GSF_nomusic)
	} else {
		s.charUpdate(&cvmin, &cvmax, &highest, &lowest, &leftest, &rightest)
	}
	s.lifebar.step()
	if s.superanim != nil {
		s.topSprites.add(&SprData{s.superanim, &s.superpmap, s.superpos,
			[...]float32{s.superfacing, 1}, [2]int32{-1}, 5, 0, 0, 0, [2]float32{},
			false, true, s.cgi[s.superplayer].ver[0] != 1, 1, 1}, 0, 0, 0, 0)
		if s.superanim.loopend {
			s.superanim = nil
		}
	}
	for i, pr := range s.projs {
		for j, p := range pr {
			if p.id >= 0 {
				s.projs[i][j].cueDraw(s.cgi[i].ver[0] != 1, i)
			}
		}
	}
	s.charList.cueDraw()
	explUpdate := func(edl *[len(s.chars)][]int, drop bool) {
		for i, el := range *edl {
			for j := len(el) - 1; j >= 0; j-- {
				if el[j] >= 0 {
					s.explods[i][el[j]].update(s.cgi[i].ver[0] != 1, i)
					if s.explods[i][el[j]].id == IErr {
						if drop {
							el = append(el[:j], el[j+1:]...)
							(*edl)[i] = el
						} else {
							el[j] = -1
						}
					}
				}
			}
		}
	}
	explUpdate(&s.explDrawlist, true)
	explUpdate(&s.topexplDrawlist, false)
	leftest -= *x
	rightest -= *x
	sclMul = s.cam.action(x, y, leftest, rightest, lowest, highest,
		cvmin, cvmax, s.super > 0 || s.pause > 0)
	introSkip := false
	if s.tickNextFrame() {
		if s.lifebar.ro.cur < 1 {
			if s.shuttertime > 0 ||
				s.anyButton() && !s.sf(GSF_roundnotskip) && s.intro > s.lifebar.ro.ctrl_time {
				s.shuttertime++
				if s.shuttertime == s.lifebar.ro.shutter_time {
					s.fadeintime = 0
					s.resetGblEffect()
					s.intro = s.lifebar.ro.ctrl_time
					for i, p := range s.chars {
						if len(p) > 0 {
							s.playerClear(i)
							p[0].selfState(0, -1, -1, 0, false)
						}
					}
					ox := *x
					*x = 0
					leftest = MaxF(float32(Min(s.stage.p[0].startx,
						s.stage.p[1].startx))*s.stage.localscl,
						-(float32(s.gameWidth)/2)/s.cam.BaseScale()+s.screenleft) - ox
					rightest = MinF(float32(Max(s.stage.p[0].startx,
						s.stage.p[1].startx))*s.stage.localscl,
						(float32(s.gameWidth)/2)/s.cam.BaseScale()-s.screenright) - ox
					introSkip = true
					s.lifebar.ro.callFight()
				}
			}
		} else {
			if s.shuttertime > 0 {
				s.shuttertime--
			}
		}
	}
	if s.lifebar.ro.act() {
		if s.intro > s.lifebar.ro.ctrl_time {
			s.intro--
			if s.sf(GSF_intro) && s.intro <= s.lifebar.ro.ctrl_time {
				s.intro = s.lifebar.ro.ctrl_time + 1
			}
		} else if s.intro > 0 {
			if s.intro == s.lifebar.ro.ctrl_time {
				for _, p := range s.chars {
					if len(p) > 0 {
						p[0].posReset()
					}
				}
			}
			s.intro--
			if s.intro == 0 {
				for _, p := range s.chars {
					if len(p) > 0 {
						p[0].unsetSCF(SCF_over)
						if p[0].ss.no == 0 {
							p[0].setCtrl(true)
						} else {
							p[0].selfState(0, -1, -1, 1, false)
						}
					}
				}
			}
		}
		if s.intro == 0 && s.time > 0 && !s.sf(GSF_timerfreeze) &&
			(s.super <= 0 || !s.superpausebg) && (s.pause <= 0 || !s.pausebg) {
			s.time--
		}
		fin := func() bool {
			if s.intro > 0 {
				return false
			}
			ko := [...]bool{true, true}
			for ii := range ko {
				for i := ii; i < len(s.chars); i += 2 {
					if len(s.chars[i]) > 0 && s.chars[i][0].teamside < 2 {
						if s.chars[i][0].alive() {
							ko[ii] = false
						} else if (s.tmode[i&1] == TM_Simul && s.loseSimul && s.com[i] == 0) ||
							(s.tmode[i&1] == TM_Tag && s.loseTag) {
							ko[ii] = true
							break
						}
					}
				}
				if ko[ii] {
					i := ii ^ 1
					for ; i < len(s.chars); i += 2 {
						if len(s.chars[i]) > 0 && s.chars[i][0].life <
							s.chars[i][0].lifeMax {
							break
						}
					}
					if i >= len(s.chars) {
						s.winType[ii^1].SetPerfect()
					}
				}
			}
			if s.time == 0 {
				//s.intro = -s.lifebar.ro.over_hittime
				l := [2]float32{}
				for i := 0; i < 2; i++ {
					for j := i; j < len(s.chars); j += 2 {
						if len(s.chars[j]) > 0 {
							if s.tmode[i] == TM_Simul || s.tmode[i] == TM_Tag {
								l[i] += (float32(s.chars[j][0].life) /
									float32(s.numSimul[i])) /
									float32(s.chars[j][0].lifeMax)
							} else {
								l[i] += float32(s.chars[j][0].life) /
									float32(s.chars[j][0].lifeMax)
							}
						}
					}
				}
				if l[0] > l[1] {
					p := true
					for i := 0; i < len(s.chars); i += 2 {
						if len(s.chars[i]) > 0 &&
							s.chars[i][0].life < s.chars[i][0].lifeMax {
							p = false
							break
						}
					}
					if p {
						s.winType[0].SetPerfect()
					}
					s.finish = FT_TO
					s.winTeam = 0
				} else if l[0] < l[1] {
					p := true
					for i := 1; i < len(s.chars); i += 2 {
						if len(s.chars[i]) > 0 &&
							s.chars[i][0].life < s.chars[i][0].lifeMax {
							p = false
							break
						}
					}
					if p {
						s.winType[1].SetPerfect()
					}
					s.finish = FT_TO
					s.winTeam = 1
				} else {
					s.finish = FT_TODraw
					s.winTeam = -1
				}
				if !(ko[0] || ko[1]) {
					s.winType[0], s.winType[1] = WT_T, WT_T
				}
			}
			if s.intro == -1 && (ko[0] || ko[1]) {
				if ko[0] && ko[1] {
					s.finish, s.winTeam = FT_DKO, -1
				} else {
					s.finish = FT_KO
					if ko[0] {
						s.winTeam = 1
					} else {
						s.winTeam = 0
					}
				}
			}
			return ko[0] || ko[1] || s.time == 0
		}
		if s.roundEnd() || fin() {
			inclWinCount := func() {
				w := [...]bool{!s.chars[1][0].win(), !s.chars[0][0].win()}
				if !w[0] || !w[1] ||
					s.tmode[0] == TM_Turns || s.tmode[1] == TM_Turns ||
					s.draws >= s.lifebar.ro.match_maxdrawgames {
					for i, win := range w {
						if win {
							s.wins[i]++
							if s.matchOver() && s.wins[^i&1] == 0 {
								s.consecutiveWins[i]++
							}
							s.consecutiveWins[^i&1] = 0
						}
					}
				}
			}
			if s.intro == -s.lifebar.ro.over_hittime && s.finish != FT_NotYet {
				inclWinCount()
			}
			rs4t := -(s.lifebar.ro.over_hittime + s.lifebar.ro.over_waittime)
			if s.winskipped || !s.sf(GSF_roundnotover) ||
				s.intro >= rs4t-s.lifebar.ro.over_wintime {
				s.intro--
				if s.intro == rs4t-1 {
					//if s.time == 0 {
					//s.intro -= s.lifebar.ro.over_wintime
					//}
					if s.waitdown > 0 {
						for _, p := range s.chars {
							if len(p) > 0 && !p[0].over() {
								s.intro = rs4t
							}
						}
					}
				}
				if s.waitdown <= 0 || s.intro < rs4t-s.lifebar.ro.over_wintime {
					if s.waitdown >= 0 {
						/*if s.finish == FT_NotYet {
							l := [2]float32{}
							for i := 0; i < 2; i++ {
								for j := i; j < len(s.chars); j += 2 {
									if len(s.chars[j]) > 0 {
										if s.tmode[i] == TM_Simul || s.tmode[i] == TM_Tag {
											l[i] += (float32(s.chars[j][0].life) /
												float32(s.numSimul[i])) /
												float32(s.chars[j][0].lifeMax)
										} else {
											l[i] += float32(s.chars[j][0].life) /
												float32(s.chars[j][0].lifeMax)
										}
									}
								}
							}
							if l[0] > l[1] {
								p := true
								for i := 0; i < len(s.chars); i += 2 {
									if len(s.chars[i]) > 0 &&
										s.chars[i][0].life < s.chars[i][0].lifeMax {
										p = false
										break
									}
								}
								if p {
									s.winType[0].SetPerfect()
								}
								s.finish = FT_TO
								s.winTeam = 0
							} else if l[0] < l[1] {
								p := true
								for i := 1; i < len(s.chars); i += 2 {
									if len(s.chars[i]) > 0 &&
										s.chars[i][0].life < s.chars[i][0].lifeMax {
										p = false
										break
									}
								}
								if p {
									s.winType[1].SetPerfect()
								}
								s.finish = FT_TO
								s.winTeam = 1
							} else {
								s.finish = FT_TODraw
								s.winTeam = -1
							}
							inclWinCount()
						}*/
						w := [...]bool{!s.chars[1][0].win(), !s.chars[0][0].win()}
						if !w[0] || !w[1] ||
							s.tmode[0] == TM_Turns || s.tmode[1] == TM_Turns ||
							s.draws >= s.lifebar.ro.match_maxdrawgames {
							for i, win := range w {
								if win {
									s.lifebar.wi[i].add(s.winType[i])
								}
							}
						} else {
							s.draws++
						}
					}
					for _, p := range s.chars {
						if len(p) > 0 {
							if s.waitdown >= 0 && p[0].win() && p[0].alive() &&
								((!s.matchOver() && (s.tmode[0] == TM_Turns || s.tmode[1] == TM_Turns)) ||
									(s.gameMode == "survival" || s.gameMode == "survivalcoop" ||
										s.gameMode == "netplaysurvivalcoop")) {
								rt := s.roundTime
								if rt < 0 {
									rt = 99 * sys.lifebar.ti.framespercount
								}
								p[0].life += int32((float32(s.time)+1)/(float32(rt)+1)*
									float32(p[0].lifeMax)*s.turnsRecoveryBonus +
									float32(p[0].lifeMax)*s.turnsRecoveryBase)
								if p[0].life > p[0].lifeMax {
									p[0].life = p[0].lifeMax
								}
							}
							if !p[0].scf(SCF_over) && !p[0].hitPause() && p[0].alive() {
								p[0].setSCF(SCF_over)
								if p[0].win() {
									p[0].selfState(180, -1, -1, 1, false)
								} else if p[0].lose() {
									p[0].selfState(170, -1, -1, 1, false)
								} else {
									p[0].selfState(175, -1, -1, 1, false)
								}
							}
						}
					}
					s.waitdown = 0
				}
				s.waitdown--
			}
		} else if s.intro < 0 {
			s.intro = 0
		}
	}
	if s.tickNextFrame() {
		spd := s.gameSpeed * s.accel
		if s.postMatchFlg {
			spd = 1
		} else if !s.sf(GSF_nokoslow) && s.time != 0 && s.intro < 0 && s.slowtime > 0 {
			spd *= s.lifebar.ro.slow_speed
			if s.slowtime < s.lifebar.ro.slow_fadetime {
				spd += (float32(1) - s.lifebar.ro.slow_speed) * float32(s.lifebar.ro.slow_fadetime-s.slowtime) / float32(s.lifebar.ro.slow_fadetime)
			}
			s.slowtime--
		}
		s.turbo = spd
	}
	s.playSound()
	if introSkip {
		sclMul = 1 / scl
	}
	leftest = (leftest - s.screenleft) * s.cam.BaseScale()
	rightest = (rightest + s.screenright) * s.cam.BaseScale()
	return
}
func (s *System) draw(x, y, scl float32) {
	ecol := uint32(s.envcol[2]&0xff | s.envcol[1]&0xff<<8 |
		s.envcol[0]&0xff<<16)
	ob := s.brightness
	s.brightness = 0x100 >> uint(Btoi(s.super > 0 && s.superdarken))
	bgx, bgy := x/s.stage.localscl, y/s.stage.localscl
	fade := func(rect [4]int32, color uint32, alpha int32) {
		FillRect(rect, color, alpha>>uint(Btoi(s.clsnDraw))+Btoi(s.clsnDraw)*128)
	}
	if s.envcol_time == 0 {
		if s.sf(GSF_nobg) {
			c := uint32(0)
			if s.allPalFX.enable {
				var rgb [3]int32
				if s.allPalFX.eInvertall {
					rgb = [...]int32{0xff, 0xff, 0xff}
				}
				for i, v := range rgb {
					rgb[i] = Max(0, Min(0xff,
						(v+s.allPalFX.eAdd[i])*s.allPalFX.eMul[i]>>8))
				}
				c = uint32(rgb[2] | rgb[1]<<8 | rgb[0]<<16)
			}
			FillRect(s.scrrect, c, 0xff)
		} else {
			if s.stage.debugbg {
				FillRect(s.scrrect, 0xff00ff, 0xff)
			}
			s.stage.draw(false, bgx, bgy, scl)
		}
		if !s.sf(GSF_globalnoshadow) {
			if s.stage.reflection > 0 {
				s.shadows.drawReflection(x, y, scl*s.cam.BaseScale())
			}
			s.shadows.draw(x, y, scl*s.cam.BaseScale())
		}
		off := s.envShake.getOffset()
		yofs, yofs2 := float32(s.gameHeight), float32(0)
		if scl > 1 && s.cam.verticalfollow > 0 {
			yofs = s.cam.screenZoff + float32(s.gameHeight-240)
			yofs2 = (240 - s.cam.screenZoff) * (1 - 1/scl)
		}
		yofs *= 1/scl - 1
		rect := s.scrrect
		if off < (yofs-y+s.cam.boundH)*scl {
			rect[3] = (int32(math.Ceil(float64(((yofs-y+s.cam.boundH)*scl-off)*
				float32(s.scrrect[3])))) + s.gameHeight - 1) / s.gameHeight
			fade(rect, 0, 255)
		}
		if off > (-y+yofs2)*scl {
			rect[3] = (int32(math.Ceil(float64(((y-yofs2)*scl+off)*
				float32(s.scrrect[3])))) + s.gameHeight - 1) / s.gameHeight
			rect[1] = s.scrrect[3] - rect[3]
			fade(rect, 0, 255)
		}
		bl, br := MinF(x, s.cam.boundL), MaxF(x, s.cam.boundR)
		xofs := float32(s.gameWidth) * (1/scl - 1) / 2
		rect = s.scrrect
		if x-xofs < bl {
			rect[2] = (int32(math.Ceil(float64((bl-(x-xofs))*scl*
				float32(s.scrrect[2])))) + s.gameWidth - 1) / s.gameWidth
			fade(rect, 0, 255)
		}
		if x+xofs > br {
			rect[2] = (int32(math.Ceil(float64(((x+xofs)-br)*scl*
				float32(s.scrrect[2])))) + s.gameWidth - 1) / s.gameWidth
			rect[0] = s.scrrect[2] - rect[2]
			fade(rect, 0, 255)
		}
		s.lifebar.draw(0)
	} else {
		FillRect(s.scrrect, ecol, 255)
	}
	if s.envcol_time == 0 || s.envcol_under {
		s.sprites.draw(x, y, scl*s.cam.BaseScale())
		if s.envcol_time == 0 && !s.sf(GSF_nofg) {
			s.stage.draw(true, bgx, bgy, scl)
		}
	}
	s.lifebar.draw(1)
	s.topSprites.draw(x, y, scl*s.cam.BaseScale())
	s.lifebar.draw(2)
	if s.fadeintime > 0 {
		fade(s.scrrect, s.lifebar.ro.fadein_col, 256*s.fadeintime/s.lifebar.ro.fadein_time)
		s.fadeintime--
	} else if s.fadeouttime > 0 && sys.intro+sys.lifebar.ro.over_hittime+sys.lifebar.ro.over_waittime+sys.lifebar.ro.over_time < s.fadeouttime-1 {
		fade(s.scrrect, s.lifebar.ro.fadeout_col, 256*(s.lifebar.ro.fadeout_time-s.fadeouttime)/s.lifebar.ro.fadeout_time)
		s.fadeouttime--
	} else if s.clsnDraw {
		fade(s.scrrect, 0, 0)
	}
	if s.shuttertime > 0 {
		rect := s.scrrect
		rect[3] = s.shuttertime * ((s.scrrect[3] + 1) >> 1) / s.lifebar.ro.shutter_time
		fade(rect, s.lifebar.ro.shutter_col, 255)
		rect[1] = s.scrrect[3] - rect[3]
		fade(rect, s.lifebar.ro.shutter_col, 255)
	}
	s.brightness = ob
	if s.clsnDraw {
		s.clsnSpr.Pal[0] = 0xff0000ff
		s.drawc1.draw(0x3feff)
		s.clsnSpr.Pal[0] = 0xffff0000
		s.drawc2.draw(0x3feff)
		s.clsnSpr.Pal[0] = 0xff00ff00
		s.drawc2sp.draw(0x3feff)
		s.clsnSpr.Pal[0] = 0xff002000
		s.drawc2mtk.draw(0x3feff)
		s.clsnSpr.Pal[0] = 0xff404040
		s.drawwh.draw(0x3feff)
		for _, t := range s.clsnText {
			sys.debugFont.DrawText(t.text, t.x, t.y, 1/sys.widthScale,
				1/sys.heightScale, 0, 1, &sys.scrrect, t.palfx, false)
		}
	}
}
func (s *System) fight() (reload bool) {
	s.gameTime, s.paused, s.accel = 0, false, 1
	s.aiInput = [len(s.aiInput)]AiInput{}
	defer func() {
		s.oldNextAddTime = 1
		s.nomusic = false
		s.allPalFX.clear()
		s.allPalFX.enable = false
		for i, p := range s.chars {
			if len(p) > 0 {
				s.playerClear(i)
			}
		}
		s.wincnt.update()
	}()
	var life, pow, gpow, spow, rlife [len(s.chars)]int32
	var ivar [len(s.chars)][]int32
	var fvar [len(s.chars)][]float32
	copyVar := func(pn int) {
		life[pn] = s.chars[pn][0].life
		pow[pn] = s.chars[pn][0].power
		gpow[pn] = s.chars[pn][0].guardPoints
		spow[pn] = s.chars[pn][0].dizzyPoints
		rlife[pn] = s.chars[pn][0].redLife
		if len(ivar[pn]) < len(s.chars[pn][0].ivar) {
			ivar[pn] = make([]int32, len(s.chars[pn][0].ivar))
		}
		copy(ivar[pn], s.chars[pn][0].ivar[:])
		if len(fvar[pn]) < len(s.chars[pn][0].fvar) {
			fvar[pn] = make([]float32, len(s.chars[pn][0].fvar))
		}
		copy(fvar[pn], s.chars[pn][0].fvar[:])
	}
	s.debugWC = sys.chars[0][0]
	debugInput := func() {
		select {
		case cl := <-s.commandLine:
			if err := s.luaLState.DoString(cl); err != nil {
				s.errLog.Println(err.Error())
			}
		default:
		}
	}
	put := func(x, y *float32, txt string) {
		tmp := s.allPalFX.enable
		s.allPalFX.enable = false
		for txt != "" {
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
			s.debugFont.DrawText(drawTxt, *x, *y,
				1/s.widthScale, 1/s.heightScale, 0, 1, &sys.scrrect,
				s.debugFont.palfx, false)
		}
		s.allPalFX.enable = tmp
	}
	drawDebug := func() {
		if s.debugDraw && s.debugFont != nil {
			//Player Info
			x := (320-float32(s.gameWidth))/2 + 1
			y := 240 - float32(s.gameHeight)
			if s.statusLFunc != nil {
				s.debugFont.palfx.setColor(255, 255, 255)
				for i, p := range s.chars {
					if len(p) > 0 {
						top := s.luaLState.GetTop()
						if s.luaLState.CallByParam(lua.P{Fn: s.statusLFunc, NRet: 1,
							Protect: true}, lua.LNumber(i+1)) == nil {
							l, ok := s.luaLState.Get(-1).(lua.LString)
							if ok && len(l) > 0 {
								put(&x, &y, string(l))
							}
						}
						s.luaLState.SetTop(top)
					}
				}
			}
			//Console
			y = MaxF(y, 48+240-float32(s.gameHeight))
			s.debugFont.palfx.setColor(255, 255, 255)
			for _, s := range s.consoleText {
				put(&x, &y, s)
			}
			//Data
			pn := s.debugRef[0]
			hn := s.debugRef[1]
			if pn >= len(s.chars) || hn >= len(s.chars[pn]) {
				s.debugRef[0] = 0
				s.debugRef[1] = 0
			}
			s.debugWC = s.chars[s.debugRef[0]][s.debugRef[1]]
			y = float32(s.gameHeight) - float32(s.debugFont.Size[1])/s.heightScale*
				(float32(len(s.listLFunc))+float32(len(s.debugWC.clipboardText))+1)
			for i, f := range s.listLFunc {
				if f != nil {
					if i == 1 {
						s.debugFont.palfx.setColor(199, 199, 219)
					} else if i > 1 && s.debugWC.ss.sb.playerNo != s.debugWC.playerNo {
						s.debugFont.palfx.setColor(255, 255, 127)
					} else {
						s.debugFont.palfx.setColor(255, 255, 255)
					}
					top := s.luaLState.GetTop()
					if s.luaLState.CallByParam(lua.P{Fn: f, NRet: 1,
						Protect: true}) == nil {
						s, ok := s.luaLState.Get(-1).(lua.LString)
						if ok && len(s) > 0 {
							if i == 1 && (sys.debugWC == nil || sys.debugWC.sf(CSF_destroy)) {
								put(&x, &y, string(s)+" disabled")
								break
							}
							put(&x, &y, string(s))

						}
					}
					s.luaLState.SetTop(top)
				}
			}
			//Clipboard
			s.debugFont.palfx.setColor(255, 255, 255)
			for _, s := range s.debugWC.clipboardText {
				put(&x, &y, s)
			}
		}
	}
	if err := s.synchronize(); err != nil {
		s.errLog.Println(err.Error())
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
			var lm float32
			if p[0].ocd().lifeMax != 0 {
				lm = float32(p[0].ocd().lifeMax) * p[0].ocd().lifeRatio * s.lifeMul
			} else {
				lm = float32(p[0].gi().data.life) * p[0].ocd().lifeRatio * s.lifeMul
			}
			switch s.tmode[i&1] {
			case TM_Single:
				switch s.tmode[(i+1)&1] {
				case TM_Simul, TM_Tag:
					lm *= s.singleVsTeamLife
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.matchWins[(i+1)&1] && s.lifeAdjustment {
						lm = lm * float32(s.numTurns[(i+1)&1]) /
							float32(s.matchWins[(i+1)&1])
					}
				}
			case TM_Simul, TM_Tag:
				switch s.tmode[(i+1)&1] {
				case TM_Simul, TM_Tag:
					if s.numSimul[(i+1)&1] < s.numSimul[i&1] && s.lifeAdjustment {
						lm = lm * float32(s.numSimul[(i+1)&1]) / float32(s.numSimul[i&1])
					}
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.numSimul[i&1]*s.matchWins[(i+1)&1] && s.lifeAdjustment {
						lm = lm * float32(s.numTurns[(i+1)&1]) /
							float32(s.numSimul[i&1]*s.matchWins[(i+1)&1])
					}
				default:
					if s.lifeAdjustment {
						lm /= float32(s.numSimul[i&1])
					}
				}
			case TM_Turns:
				switch s.tmode[(i+1)&1] {
				case TM_Single:
					if s.matchWins[i&1] < s.numTurns[i&1] && s.lifeAdjustment {
						lm = lm * float32(s.matchWins[i&1]) / float32(s.numTurns[i&1])
					}
				case TM_Simul, TM_Tag:
					if s.numSimul[(i+1)&1]*s.matchWins[i&1] < s.numTurns[i&1] && s.lifeAdjustment {
						lm = lm * s.singleVsTeamLife *
							float32(s.numSimul[(i+1)&1]*s.matchWins[i&1]) /
							float32(s.numTurns[i&1])
					}
				case TM_Turns:
					if s.numTurns[(i+1)&1] < s.numTurns[i&1] && s.lifeAdjustment {
						lm = lm * float32(s.numTurns[(i+1)&1]) / float32(s.numTurns[i&1])
					}
				}
			}
			foo := math.Pow(lvmul, float64(-level[i]))
			p[0].lifeMax = Max(1, int32(math.Floor(foo*float64(lm))))
			if s.roundsExisted[i&1] > 0 {
				p[0].life = Min(p[0].lifeMax, int32(math.Ceil(foo*float64(p[0].life))))
			} else if s.round == 1 || s.tmode[i&1] == TM_Turns {
				if p[0].ocd().life != 0 {
					p[0].life = p[0].ocd().life
				} else {
					p[0].life = p[0].lifeMax
				}
				if s.round == 1 {
					if s.maxPowerMode {
						p[0].power = p[0].powerMax
					} else {
						p[0].power = p[0].ocd().power //p[0].power = 0
					}
				}
				p[0].mapArray = make(map[string]float32)
				for k, v := range p[0].mapDefault {
					p[0].mapArray[k] = v
				}
				p[0].remapSpr = make(RemapPreset)
			}
			if p[0].ocd().guardPoints != 0 {
				p[0].guardPoints = p[0].ocd().guardPoints
			} else {
				p[0].guardPoints = p[0].guardPointsMax
			}
			if p[0].ocd().dizzyPoints != 0 {
				p[0].dizzyPoints = p[0].ocd().dizzyPoints
			} else {
				p[0].dizzyPoints = p[0].dizzyPointsMax
			}
			p[0].redLife = 0
			copyVar(i)
		}
	}
	if s.round == 1 && s.gameMode == "" {
		s.bgm.Open(s.stage.bgmusic, true, 1, 100, 0, 0)
	}
	s.cam.stageCamera = s.stage.stageCamera
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
				p[0].guardPoints = gpow[i]
				p[0].dizzyPoints = spow[i]
				p[0].redLife = rlife[i]
				copy(p[0].ivar[:], ivar[i])
				copy(p[0].fvar[:], fvar[i])
			}
		}
		s.resetFrameTime()
		s.nextRound()
		x, y, newx, newy, l, r, sclmul = 0, 0, 0, 0, 0, 0, 1
		scl = s.cam.startzoom
		s.cam.Update(scl, x, y)
	}
	reset()
	fin := false
	for !s.endMatch {
		s.step, s.roundResetFlg, s.reloadFlg = false, false, false
		for _, v := range s.shortcutScripts {
			if v.Activate {
				if err := s.luaLState.DoString(v.Script); err != nil {
					s.errLog.Println(err.Error())
				}
			}
		}
		if s.roundOver() && !fin {
			s.round++
			for i := range s.roundsExisted {
				s.roundsExisted[i]++
			}
			var scr [2]float32
			tbl_roundNo := s.luaLState.NewTable()
			for i, p := range s.chars {
				if len(p) > 0 {
					tmp := s.luaLState.NewTable()
					tmp.RawSetString("name", lua.LString(p[0].name))
					tmp.RawSetString("id", lua.LNumber(p[0].id))
					tmp.RawSetString("memberNo", lua.LNumber(p[0].memberNo))
					tmp.RawSetString("selectNo", lua.LNumber(p[0].selectNo))
					tmp.RawSetString("teamside", lua.LNumber(p[0].teamside))
					tmp.RawSetString("life", lua.LNumber(p[0].life))
					tmp.RawSetString("lifeMax", lua.LNumber(p[0].lifeMax))
					tmp.RawSetString("winquote", lua.LNumber(p[0].winquote))
					tmp.RawSetString("aiLevel", lua.LNumber(p[0].aiLevel()))
					tmp.RawSetString("palno", lua.LNumber(p[0].palno()))
					tmp.RawSetString("win", lua.LBool(p[0].win()))
					tmp.RawSetString("winKO", lua.LBool(p[0].winKO()))
					tmp.RawSetString("winTime", lua.LBool(p[0].winTime()))
					tmp.RawSetString("winPerfect", lua.LBool(p[0].winPerfect()))
					tmp.RawSetString("winNormal", lua.LBool(p[0].winNormal()))
					tmp.RawSetString("winSpecial", lua.LBool(p[0].winSpecial()))
					tmp.RawSetString("winHyper", lua.LBool(p[0].winHyper()))
					tmp.RawSetString("winCheese", lua.LBool(p[0].winCheese()))
					tmp.RawSetString("winThrow", lua.LBool(p[0].winThrow()))
					tmp.RawSetString("winSuicide", lua.LBool(p[0].winSuicide()))
					tmp.RawSetString("winTeammate", lua.LBool(p[0].winTeammate()))
					tmp.RawSetString("drawgame", lua.LBool(p[0].drawgame()))
					tmp.RawSetString("ko", lua.LBool(p[0].scf(SCF_ko)))
					tmp.RawSetString("ko_round_middle", lua.LBool(p[0].scf(SCF_ko_round_middle)))
					tmp.RawSetString("score", lua.LNumber(p[0].scoreCurrent))
					tmp.RawSetString("firstAttack", lua.LBool(p[0].firstAttack))
					tmp.RawSetString("cheated", lua.LBool(p[0].cheated))
					tbl_roundNo.RawSetInt(p[0].playerNo+1, tmp)
					scr[i&1] += p[0].scoreCurrent
					p[0].scoreCurrent = 0
					p[0].damageCount = 0
					p[0].firstAttack = false
					p[0].cheated = false
				}
			}
			s.matchData.RawSetInt(int(s.round-1), tbl_roundNo)
			s.scoreRounds = append(s.scoreRounds, scr)
			if !s.matchOver() && (s.tmode[0] != TM_Turns || s.chars[0][0].win()) &&
				(s.tmode[1] != TM_Turns || s.chars[1][0].win()) {
				for i, p := range s.chars {
					if len(p) > 0 {
						if s.tmode[i&1] != TM_Turns || !p[0].win() {
							p[0].life = p[0].lifeMax
						} else if p[0].life <= 0 {
							p[0].life = 1
						}
						p[0].redLife = 0
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
				}
				if !s.matchOver() {
					break
				}
				s.postMatchFlg = true
				fin = true
			}
		}
		scl = s.cam.ScaleBound(scl, sclmul)
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
		if s.roundResetFlg && !s.postMatchFlg {
			reset()
		}
		if s.reloadFlg {
			return true
		}
		debugInput()
		if !s.addFrameTime(s.turbo) {
			if !s.eventUpdate() {
				return false
			}
			continue
		}
		if !s.frameSkip {
			dx, dy, dscl := x, y, scl
			if s.enableZoomstate {
				if !s.debugPaused() {
					s.zoomPosXLag += ((s.zoomPos[0] - s.zoomPosXLag) * (1 - s.zoomlag))
					s.zoomPosYLag += ((s.zoomPos[1] - s.zoomPosYLag) * (1 - s.zoomlag))
					s.drawScale = s.drawScale / (s.drawScale + (s.zoomScale*scl-s.drawScale)*s.zoomlag) * s.zoomScale * scl
				}
				dscl = MaxF(s.cam.MinScale, s.drawScale/s.cam.BaseScale())
				dx = s.cam.XBound(dscl, x+s.zoomPosXLag/scl)
				dy = y + s.zoomPosYLag
			} else {
				s.zoomlag = 0
				s.zoomPosXLag = 0
				s.zoomPosYLag = 0
				s.zoomScale = 1
				s.zoomPos = [2]float32{0, 0}
				s.drawScale = s.cam.Scale
			}
			s.draw(dx, dy, dscl)
			drawDebug()
		}
		for _, str := range s.commonLua {
			if err := s.luaLState.DoString(str); err != nil {
				s.warnConsole(fmt.Sprintf("WARNING: Failed to execute config.json CommonLua code: %v\n", str))
				s.errLog.Println(err.Error())
			}
		}
		if fin && (!s.postMatchFlg || len(sys.commonLua) == 0) {
			break
		}
		if !s.update() {
			break
		}
		if s.gameMode == "arcade" && s.com[1] > 0 {
			if s.keyConfig[s.inputRemap[1]].s() || s.joystickConfig[s.inputRemap[1]].s() {
				s.challenger = 2
			}
			if s.challenger > 0 && s.lifebar.ch.challenger.cnt >= s.lifebar.ch.over_time {
				s.endMatch = true
			}
		} else if s.gameMode == "demo" && (s.esc || s.anyButton() || s.gameTime >= s.demoTime) {
			s.endMatch = true
		}
		if s.endMatch {
			s.esc = true
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
		if str[:3] == "\ufeff" {
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
func (wm *wincntMap) update() {
	winPoint := func(i int) int32 {
		if sys.tmode[(i+1)&1] == TM_Simul || sys.tmode[(i+1)&1] == TM_Tag {
			if sys.tmode[i&1] != TM_Simul && sys.tmode[i&1] != TM_Tag {
				return sys.numSimul[(i+1)&1]
			} else if sys.numSimul[(i+1)&1] > sys.numSimul[i&1] {
				return sys.numSimul[(i+1)&1] / sys.numSimul[i&1]
			}
		}
		return 1
	}
	win := func(i int) {
		item := wm.getItem(sys.cgi[i].def)
		item[sys.cgi[i].palno-1] += winPoint(i)
		wm.setItem(i, item)
	}
	lose := func(i int) {
		item := wm.getItem(sys.cgi[i].def)
		item[sys.cgi[i].palno-1] -= winPoint(i)
		wm.setItem(i, item)
	}
	if sys.autolevel && sys.matchOver() {
		for i, p := range sys.chars {
			if len(p) > 0 {
				if p[0].win() {
					win(i)
				} else if p[0].lose() {
					lose(i)
				}
			}
		}
		var str string
		for k, v := range *wm {
			str += k + ","
			for _, w := range v {
				str += fmt.Sprintf(" %v", w)
			}
			str += "\r\n"
		}
		f, err := os.Create(sys.wincntFileName)
		if err == nil {
			f.Write([]byte(str))
			chk(f.Close())
		}
	}
}
func (wm wincntMap) getItem(def string) []int32 {
	lv := wm[def]
	if len(lv) < MaxPalNo {
		lv = append(lv, make([]int32, MaxPalNo-len(lv))...)
	}
	return lv
}
func (wm wincntMap) setItem(pn int, item []int32) {
	var ave, palcnt int32 = 0, 0
	for i, v := range item {
		if sys.cgi[pn].palSelectable[i] {
			ave += v
			palcnt++
		}
	}
	ave /= palcnt
	for i := range item {
		if !sys.cgi[pn].palSelectable[i] {
			item[i] = ave
		}
	}
	wm[sys.cgi[pn].def] = item
}
func (wm wincntMap) getLevel(p int) int32 {
	return wm.getItem(sys.cgi[p].def)[sys.cgi[p].palno-1]
}

type SelectChar struct {
	def               string
	name              string
	author            string
	sprite            string
	sound             string
	intro_storyboard  string
	ending_storyboard string
	pal               []int32
	pal_defaults      []int32
	pal_keymap        []int32
	sportrait         *Sprite
	lportrait         *Sprite
	portrait          map[[2]int16]*Sprite
	portrait_scale    float32
	movelist          string
}

func newSelectChar() *SelectChar {
	return &SelectChar{portrait: make(map[[2]int16]*Sprite), portrait_scale: 1}
}

type SelectStage struct {
	def             string
	name            string
	spr             string
	attachedchardef string
	stagebgm        IniSection
	portrait        map[[2]int16]*Sprite
	portraitScale   float32
	xscale          float32
	yscale          float32
}

func newSelectStage() *SelectStage {
	return &SelectStage{portrait: make(map[[2]int16]*Sprite), portraitScale: 1,
		xscale: 1, yscale: 1}
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
	aportrait       map[string]Anim
	charPreloading  [][2]int16
	stagePreloading [][2]int16
	cdefOverwrite   [MaxSimul * 2]string
	sdefOverwrite   string
}

func newSelect() *Select {
	return &Select{columns: 5, rows: 2, randomscl: [...]float32{1, 1},
		cellsize: [...]float32{29, 29}, cellscale: [...]float32{1, 1},
		selectedStageNo: -1, aportrait: make(map[string]Anim)}
}

func (s *Select) Reset() {
	*s = *newSelect()
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
func (s *Select) GetStageAttachedChar(n int) string {
	n %= len(s.stagelist) + 1
	if n < 0 {
		n += len(s.stagelist) + 1
	}
	return s.stagelist[n-1].attachedchardef
}
func (s *Select) GetStageBgm(n int) IniSection {
	n %= len(s.stagelist) + 1
	if n < 0 {
		n += len(s.stagelist) + 1
	}
	return s.stagelist[n-1].stagebgm
}
func (s *Select) GetStage(n int) *SelectStage {
	if len(s.stagelist) == 0 {
		return nil
	}
	n %= len(s.stagelist) + 1
	if n < 0 {
		n += len(s.stagelist) + 1
	}
	return &s.stagelist[n-1]
}
func (s *Select) addChar(def string) {
	var tstr string
	tnow := time.Now()
	defer func() {
		sys.loadTime(tnow, tstr, false, false)
	}()
	s.charlist = append(s.charlist, *newSelectChar())
	sc := &s.charlist[len(s.charlist)-1]
	def = strings.Replace(strings.TrimSpace(strings.Split(def, ",")[0]),
		"\\", "/", -1)
	tstr = fmt.Sprintf("Char added: %v", def)
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
	if strings.ToLower(def[0:6]) != "chars/" && strings.ToLower(def[1:3]) != ":/" && (def[0] != '/' || idx > 0 && !strings.Contains(def[:idx], ":")) {
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
	lines, i, info, files, keymap, arcade := SplitAndTrim(str, "\n"), 0, true, true, true, true
	sprite, sound, movelist := "", "", ""
	for i < len(lines) {
		is, name, subname := ReadIniSection(lines, &i)
		switch name {
		case "info":
			if info {
				info = false
				var ok bool
				if sc.name, ok, _ = is.getText("displayname"); !ok {
					sc.name, _, _ = is.getText("name")
				}
				sc.author, _, _ = is.getText("author")
				sc.pal_defaults = is.readI32CsvForStage("pal.defaults")
				if ok = is.ReadF32("localcoord", &sc.portrait_scale); ok {
					sc.portrait_scale = (320 / sc.portrait_scale)
				}
				is.ReadF32("portraitscale", &sc.portrait_scale)
			}
		case "files":
			if files {
				files = false
				sprite = is["sprite"]
				sound = is["sound"]
				for i := 1; i <= MaxPalNo; i++ {
					if is[fmt.Sprintf("pal%v", i)] != "" {
						sc.pal = append(sc.pal, int32(i))
					}
				}
				movelist = is["movelist"]
			}
		case "palette ":
			if keymap &&
				len(subname) >= 6 && strings.ToLower(subname[:6]) == "keymap" {
				keymap = false
				for _, v := range [12]string{"a", "b", "c", "x", "y", "z",
					"a2", "b2", "c2", "x2", "y2", "z2"} {
					var i32 int32
					if is.ReadI32(v, &i32) {
						sc.pal_keymap = append(sc.pal_keymap, i32)
					}
				}
			}
		case "arcade":
			if arcade {
				arcade = false
				sc.intro_storyboard, _ = is.getString("intro.storyboard")
				sc.ending_storyboard, _ = is.getString("ending.storyboard")
			}
		}
	}
	sc.sprite = sprite
	if len(s.charPreloading) > 0 || len(sc.pal) == 0 || sys.legacyMode {
		LoadFile(&sprite, def, func(file string) error {
			var err error
			if sys.legacyMode {
				if sc.sportrait, err = loadFromSff(file, 9000, 0); err != nil {
					sc.sportrait = newSprite()
				}
				if sc.lportrait, err = loadFromSff(file, 9000, 1); err != nil {
					sc.lportrait = newSprite()
				}
			} else {
				for _, v := range s.charPreloading {
					if _, ok := sc.portrait[[...]int16{v[0], v[1]}]; !ok {
						if sc.portrait[[...]int16{v[0], v[1]}], err = loadFromSff(file, v[0], v[1]); err != nil {
							sc.portrait[[...]int16{v[0], v[1]}] = newSprite()
						}
					}
				}
			}
			if len(sc.pal) == 0 {
				sc.pal, _ = selectablePalettes(file)
			}
			return nil
		})
	}
	sc.sound = sound
	if len(movelist) > 0 {
		LoadFile(&movelist, def, func(file string) error {
			sc.movelist, _ = LoadText(file)
			return nil
		})
	}
}
func (s *Select) AddStage(def string) error {
	var tstr string
	tnow := time.Now()
	defer func() {
		sys.loadTime(tnow, tstr, false, false)
	}()
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
	tstr = fmt.Sprintf("Stage added: %v", def)
	i, info, music, bgdef, stageinfo := 0, true, true, true, true
	s.stagelist = append(s.stagelist, *newSelectStage())
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
				ss.attachedchardef, _ = is.getString("attachedchar")
			}
		case "music":
			if music {
				music = false
				ss.stagebgm = is
			}
		case "bgdef":
			if bgdef {
				bgdef = false
				ss.spr = is["spr"]
				if len(s.stagePreloading) > 0 {
					LoadFile(&ss.spr, def, func(file string) error {
						var err error
						for _, v := range s.stagePreloading {
							if _, ok := ss.portrait[[...]int16{v[0], v[1]}]; !ok {
								if ss.portrait[[...]int16{v[0], v[1]}], err = loadFromSff(file, v[0], v[1]); err != nil {
									ss.portrait[[...]int16{v[0], v[1]}] = newSprite()
								}
							}
						}
						return nil
					})
				}
			}
		case "stageinfo":
			if stageinfo {
				stageinfo = false
				if ok := is.ReadF32("localcoord", &ss.portraitScale); ok {
					ss.portraitScale = (320 / ss.portraitScale)
				}
				if ok := is.ReadF32("portraitscale", &ss.portraitScale); !ok {
					is.ReadF32("xscale", &ss.xscale)
					is.ReadF32("yscale", &ss.yscale)
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
		pl = int(Rand(1, MaxPalNo))
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
	if sys.tmode[pn&1] == TM_Simul || sys.tmode[pn&1] == TM_Tag {
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
	if result < 0 && nsel <= memberNo {
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
	var tstr string
	tnow := time.Now()
	defer func() {
		sys.loadTime(tnow, tstr, false, true)
	}()
	var cdef string
	var cdefOWnumber int
	if sys.tmode[pn&1] == TM_Turns {
		cdefOWnumber = memberNo*2 + pn&1
	} else {
		cdefOWnumber = pn
	}
	if sys.sel.cdefOverwrite[cdefOWnumber] != "" {
		cdef = sys.sel.cdefOverwrite[cdefOWnumber]
	} else {
		cdef = sys.sel.charlist[idx[memberNo]].def
	}
	var p *Char
	if len(sys.chars[pn]) > 0 && cdef == sys.cgi[pn].def {
		p = sys.chars[pn][0]
		p.key = pn
		if sys.com[pn] != 0 {
			p.key ^= -1
		}
	} else {
		p = newChar(pn, 0)
		sys.cgi[pn].sff = nil
		if len(sys.chars[pn]) > 0 {
			p.power = sys.chars[pn][0].power
			p.guardPoints = sys.chars[pn][0].guardPoints
			p.dizzyPoints = sys.chars[pn][0].dizzyPoints
		}
	}
	p.memberNo = memberNo
	p.selectNo = sys.sel.selected[pn&1][memberNo][0]
	p.teamside = p.playerNo & 1
	sys.chars[pn] = make([]*Char, 1)
	sys.chars[pn][0] = p
	if sys.cgi[pn].sff == nil {
		if sys.cgi[pn].states, l.err =
			newCompiler().Compile(p.playerNo, cdef); l.err != nil {
			sys.chars[pn] = nil
			tstr = fmt.Sprintf("WARNING: Failed to compile new char states: %v", cdef)
			return -1
		}
		if l.err = p.load(cdef); l.err != nil {
			sys.chars[pn] = nil
			tstr = fmt.Sprintf("WARNING: Failed to load new char: %v", cdef)
			return -1
		}
		tstr = fmt.Sprintf("New char loaded: %v", cdef)
	} else {
		tstr = fmt.Sprintf("Cached char loaded: %v", cdef)
	}
	if sys.roundsExisted[pn&1] == 0 {
		sys.cgi[pn].palno = pal //sys.cgi[pn].palkeymap[pal-1] + 1
	}
	if pn < len(sys.lifebar.fa[sys.tmode[pn&1]]) &&
		sys.tmode[pn&1] == TM_Turns && sys.round == 1 {
		fa := sys.lifebar.fa[sys.tmode[pn&1]][pn]
		fa.numko, fa.teammate_face, fa.teammate_scale = 0, make([]*Sprite, nsel), make([]float32, nsel)
		for i, ci := range idx {
			sprite := sys.sel.charlist[ci].sprite
			LoadFile(&sprite, sys.sel.charlist[ci].def, func(file string) error {
				var err error
				fa.teammate_face[i], err = loadFromSff(file,
					int16(fa.teammate_face_spr[0]), int16(fa.teammate_face_spr[1]))
				fa.teammate_scale[i] = sys.sel.charlist[ci].portrait_scale
				return err
			})
		}
	}
	return 1
}

func (l *Loader) loadAttachedChar(atcpn int, def string) int {
	var tstr string
	tnow := time.Now()
	defer func() {
		sys.loadTime(tnow, tstr, false, true)
	}()
	pn := atcpn + MaxSimul*2
	cdef := def
	var p *Char
	if len(sys.chars[pn]) > 0 && cdef == sys.cgi[pn].def {
		p = sys.chars[pn][0]
		p.key = -pn
	} else {
		p = newChar(pn, 0)
		sys.cgi[pn].sff = nil
		if len(sys.chars[pn]) > 0 {
			p.power = sys.chars[pn][0].power
			p.guardPoints = sys.chars[pn][0].guardPoints
			p.dizzyPoints = sys.chars[pn][0].dizzyPoints
		}
	}
	p.memberNo = -atcpn
	p.selectNo = -atcpn
	p.teamside = 2
	sys.com[pn] = 8
	sys.chars[pn] = make([]*Char, 1)
	sys.chars[pn][0] = p
	if sys.cgi[pn].sff == nil {
		if sys.cgi[pn].states, l.err =
			newCompiler().Compile(p.playerNo, cdef); l.err != nil {
			sys.chars[pn] = nil
			tstr = fmt.Sprintf("WARNING: Failed to compile new attachedchar states: %v", cdef)
			return -1
		}
		if l.err = p.load(cdef); l.err != nil {
			sys.chars[pn] = nil
			tstr = fmt.Sprintf("WARNING: Failed to load new attachedchar: %v", cdef)
			return -1
		}
		tstr = fmt.Sprintf("New attachedchar loaded: %v", cdef)
	} else {
		tstr = fmt.Sprintf("Cached attachedchar loaded: %v", cdef)
	}
	if sys.roundsExisted[pn&1] == 0 {
		sys.cgi[pn].palno = 1
	}
	return 1
}

func (l *Loader) loadStage() bool {
	if sys.round == 1 {
		var def string
		if sys.sel.selectedStageNo == 0 {
			randomstageno := Rand(0, int32(len(sys.sel.stagelist))-1)
			def = sys.sel.stagelist[randomstageno].def
		} else {
			def = sys.sel.stagelist[sys.sel.selectedStageNo-1].def
		}
		if sys.sel.sdefOverwrite != "" {
			def = sys.sel.sdefOverwrite
		}
		if sys.stage != nil && sys.stage.def == def {
			if sys.stage.attachedchardef != "" {
				l.loadAttachedChar(0, sys.stage.attachedchardef)
			}
			return true
		}
		sys.stage, l.err = loadStage(def, true)
		if sys.stage.attachedchardef != "" {
			l.loadAttachedChar(0, sys.stage.attachedchardef)
		}
	}
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
				sys.tmode[i] != TM_Simul && sys.tmode[i] != TM_Tag {
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
