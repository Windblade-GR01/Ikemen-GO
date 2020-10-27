package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"unicode"
)

const (
	IMax = int32(^uint32(0) >> 1)
	IErr = ^IMax
)

func Random() int32 {
	w := sys.randseed / 127773
	sys.randseed = (sys.randseed-w*127773)*16807 - w*2836
	if sys.randseed <= 0 {
		sys.randseed += IMax - Btoi(sys.randseed == 0)
	}
	return sys.randseed
}
func Srand(s int32)             { sys.randseed = s }
func Rand(min, max int32) int32 { return min + Random()/(IMax/(max-min+1)+1) }

func RandF32(min, max float32) float32 {
	return min + float32(Random())/(float32(IMax)/(max-min+1.0)+1.0)
}

func RandI(x, y int32) int32 {
	if y < x {
		if uint32(x-y) > uint32(IMax) {
			return int32(int64(y) + int64(Random())*(int64(x)-int64(y))/int64(IMax))
		}
		return Rand(y, x)
	}
	if uint32(y-x) > uint32(IMax) {
		return int32(int64(x) + int64(Random())*(int64(y)-int64(x))/int64(IMax))
	}
	return Rand(x, y)
}
func RandF(x, y float32) float32 {
	return x + float32(Random())*(y-x)/float32(IMax)
}
func Min(arg ...int32) (min int32) {
	if len(arg) > 0 {
		min = arg[0]
		for i := 1; i < len(arg); i++ {
			if arg[i] < min {
				min = arg[i]
			}
		}
	}
	return
}
func Max(arg ...int32) (max int32) {
	if len(arg) > 0 {
		max = arg[0]
		for i := 1; i < len(arg); i++ {
			if arg[i] > max {
				max = arg[i]
			}
		}
	}
	return
}
func MinF(arg ...float32) (min float32) {
	if len(arg) > 0 {
		min = arg[0]
		for i := 1; i < len(arg); i++ {
			if arg[i] < min {
				min = arg[i]
			}
		}
	}
	return
}
func MaxF(arg ...float32) (max float32) {
	if len(arg) > 0 {
		max = arg[0]
		for i := 1; i < len(arg); i++ {
			if arg[i] > max {
				max = arg[i]
			}
		}
	}
	return
}
func Abs(i int32) int32 {
	if i < 0 {
		return -i
	}
	return i
}
func AbsF(f float32) float32 {
	if f < 0 {
		return -f
	}
	return f
}
func Pow(x, y float32) float32 {
	return float32(math.Pow(float64(x), float64(y)))
}
func IsFinite(f float32) bool {
	return math.Abs(float64(f)) <= math.MaxFloat64
}
func Atoi(str string) int32 {
	n := int32(0)
	str = strings.TrimSpace(str)
	if len(str) > 0 {
		var a string
		if str[0] == '-' || str[0] == '+' {
			a = str[1:]
		} else {
			a = str
		}
		for i := range a {
			if a[i] < '0' || '9' < a[i] {
				break
			}
			n = n*10 + int32(a[i]-'0')
		}
		if str[0] == '-' {
			n *= -1
		}
	}
	return n
}
func Atof(str string) float64 {
	f := 0.0
	str = strings.TrimSpace(str)
	if len(str) > 0 {
		var a string
		if str[0] == '-' || str[0] == '+' {
			a = str[1:]
		} else {
			a = str
		}
		i, p := 0, 0
		for ; i < len(a); i++ {
			if a[i] == '.' {
				if p != 0 {
					break
				}
				p = i + 1
				continue
			}
			if a[i] < '0' || '9' < a[i] {
				break
			}
			f = f*10 + float64(a[i]-'0')
		}
		e := 0.0
		if i+1 < len(a) && (a[i] == 'e' || a[i] == 'E') {
			j := i + 1
			if a[j] == '-' || a[j] == '+' {
				j++
			}
			for ; j < len(a) && '0' <= a[j] && a[j] <= '9'; j++ {
				e = e*10 + float64(a[j]-'0')
			}
			if e != 0 {
				if str[i+1] == '-' {
					e *= -1
				}
				if p == 0 {
					p = i
				}
			}
		}
		if p > 0 {
			f *= math.Pow10(p - i + int(e))
		}
		if str[0] == '-' {
			f *= -1
		}
	}
	return f
}
func readDigit(d string) (int32, bool) {
	if len(d) == 0 || (len(d) >= 2 && d[0] == '0') {
		return 0, false
	}
	for _, c := range d {
		if c < '0' || c > '9' {
			return 0, false
		}
	}
	return int32(Atof(d)), true
}
func Btoi(b bool) int32 {
	if b {
		return 1
	}
	return 0
}
func I32ToI16(i32 int32) int16 {
	if i32 < ^int32(^uint16(0)>>1) {
		return ^int16(^uint16(0) >> 1)
	}
	if i32 > int32(^uint16(0)>>1) {
		return int16(^uint16(0) >> 1)
	}
	return int16(i32)
}
func I32ToU16(i32 int32) uint16 {
	if i32 < 0 {
		return 0
	}
	if i32 > int32(^uint16(0)) {
		return ^uint16(0)
	}
	return uint16(i32)
}
func LoadText(filename string) (string, error) {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		return "", err
	}
	if len(bytes) >= 3 &&
		bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf {
		bytes = bytes[3:]
	}
	return string(bytes), nil
}
func FileExist(filename string) string {
	if _, err := os.Stat(filename); !os.IsNotExist(err) {
		return filename
	}
	var pattern string
	for _, r := range filename {
		if r >= 'A' && r <= 'Z' || r >= 'a' && r <= 'z' {
			pattern += "[" + string(unicode.ToLower(r)) +
				string(unicode.ToLower(r)+'A'-'a') + "]"
		} else if r == '*' || r == '?' || r == '[' {
			pattern += "\\" + string(r)
		} else {
			pattern += string(r)
		}
	}
	if m, _ := filepath.Glob(pattern); len(m) > 0 {
		return m[0]
	}
	return ""
}

//SearchFile returns the directory that file is located
//This search on deffile directory, then it keep looking on other dirs
func SearchFile(file string, deffile string) string {
	var fp string
	file = strings.Replace(file, "\\", "/", -1)
	defdir := filepath.Dir(strings.Replace(deffile, "\\", "/", -1))
	if defdir == "." || strings.Contains(file, ":/") {
		fp = file
	} else if defdir == "/" {
		fp = "/" + file
	} else {
		fp = defdir + "/" + file
	}
	if fp = FileExist(fp); len(fp) == 0 {
		_else := false
		if defdir != "data" {
			fp = "data/" + file
			if fp = FileExist(fp); len(fp) == 0 {
				fp = sys.motifDir + file
				if fp = FileExist(fp); len(fp) == 0 {
					_else = true
				}
			}
		} else {
			_else = true
		}
		if _else {
			fp = file
			if fp = FileExist(fp); len(fp) == 0 {
				fp = file
			}
		}
	}

	return fp
}

func LoadFile(file *string, deffile string, load func(string) error) error {
	fp := SearchFile(*file, deffile)
	if err := load(fp); err != nil {
		return Error(deffile + ":\n" + fp + "\n" + err.Error())
	}
	*file = fp
	return nil
}

func SplitAndTrim(str, sep string) (ss []string) {
	ss = strings.Split(str, sep)
	for i, s := range ss {
		ss[i] = strings.TrimSpace(s)
	}
	return
}
func OldSprintf(f string, a ...interface{}) (s string) {
	iIdx, lIdx, numVerbs := []int{}, []int{}, 0
	for i := 0; i < len(f); i++ {
		if f[i] == '%' {
			i++
			if i >= len(f) {
				break
			}
			for ; i < len(f) && (f[i] == ' ' || f[i] == '0' ||
				f[i] == '-' || f[i] == '+' || f[i] == '#'); i++ {
			}
			if i >= len(f) {
				break
			}
			for ; i < len(f) && f[i] >= '0' && f[i] <= '9'; i++ {
			}
			if i >= len(f) {
				break
			}
			if f[i] == '.' {
				for i++; i < len(f) && f[i] >= '0' && f[i] <= '9'; i++ {
				}
				if i >= len(f) {
					break
				}
			}
			if f[i] == 'h' || f[i] == 'l' || f[i] == 'L' {
				lIdx = append(lIdx, i)
				i++
			}
			if f[i] == '%' {
				continue
			}
			numVerbs++
			if f[i] == 'i' || f[i] == 'u' {
				iIdx = append(iIdx, i)
			}
		}
	}
	if len(iIdx) > 0 || len(lIdx) > 0 {
		b := []byte(f)
		for _, i := range iIdx {
			b[i] = 'd'
		}
		for i := len(lIdx) - 1; i >= 0; i-- {
			b = append(b[:lIdx[i]], b[lIdx[i]+1:]...)
		}
		f = string(b)
	}
	if len(a) > numVerbs {
		a = a[:numVerbs]
	}
	return fmt.Sprintf(f, a...)
}
func SectionName(sec string) (string, string) {
	if len(sec) == 0 || sec[0] != '[' {
		return "", ""
	}
	sec = strings.TrimSpace(strings.SplitN(sec, ";", 2)[0])
	if sec[len(sec)-1] != ']' {
		return "", ""
	}
	sec = sec[1:strings.Index(sec, "]")]
	var name string
	i := strings.Index(sec, " ")
	if i >= 0 {
		name = sec[:i+1]
		sec = sec[i+1:]
	} else {
		name = sec
		sec = ""
	}
	return strings.ToLower(name), sec
}
func HasExtension(file, ext string) bool {
	match, _ := regexp.MatchString(ext, filepath.Ext(file))
	return match
}

func sliceInsertInt(array []int, value int, index int) []int {
	return append(array[:index], append([]int{value}, array[index:]...)...)
}

func sliceRemoveInt(array []int, index int) []int {
	return append(array[:index], array[index+1:]...)
}

func sliceMoveInt(array []int, srcIndex int, dstIndex int) []int {
	value := array[srcIndex]
	return sliceInsertInt(sliceRemoveInt(array, srcIndex), value, dstIndex)
}

type Error string

func (e Error) Error() string { return string(e) }

type IniSection map[string]string

func NewIniSection() IniSection { return IniSection(make(map[string]string)) }
func ReadIniSection(lines []string, i *int) (
	is IniSection, name string, subname string) {
	for ; *i < len(lines); (*i)++ {
		name, subname = SectionName(lines[*i])
		if len(name) > 0 {
			(*i)++
			break
		}
	}
	if len(name) == 0 {
		return
	}
	is = NewIniSection()
	is.Parse(lines, i)
	return
}
func (is IniSection) Parse(lines []string, i *int) {
	for ; *i < len(lines); (*i)++ {
		if len(lines[*i]) > 0 && lines[*i][0] == '[' {
			break
		}
		line := strings.TrimSpace(strings.SplitN(lines[*i], ";", 2)[0])
		ia := strings.IndexAny(line, "= \t")
		if ia > 0 {
			name := strings.ToLower(line[:ia])
			var data string
			ia = strings.Index(line, "=")
			if ia >= 0 {
				data = strings.TrimSpace(line[ia+1:])
			}
			_, ok := is[name]
			if !ok {
				is[name] = data
			}
		}
	}
}
func (is IniSection) LoadFile(name, deffile string,
	load func(string) error) error {
	str := is[name]
	if len(str) == 0 {
		return nil
	}
	return LoadFile(&str, deffile, load)
}
func (is IniSection) ReadI32(name string, out ...*int32) bool {
	str := is[name]
	if len(str) == 0 {
		return false
	}
	for i, s := range strings.Split(str, ",") {
		if i >= len(out) {
			break
		}
		if s = strings.TrimSpace(s); len(s) > 0 {
			*out[i] = Atoi(s)
		}
	}
	return true
}
func (is IniSection) ReadF32(name string, out ...*float32) bool {
	str := is[name]
	if len(str) == 0 {
		return false
	}
	for i, s := range strings.Split(str, ",") {
		if i >= len(out) {
			break
		}
		if s = strings.TrimSpace(s); len(s) > 0 {
			*out[i] = float32(Atof(s))
		}
	}
	return true
}
func (is IniSection) ReadBool(name string, out ...*bool) bool {
	str := is[name]
	if len(str) == 0 {
		return false
	}
	for i, s := range strings.Split(str, ",") {
		if i >= len(out) {
			break
		}
		if s = strings.TrimSpace(s); len(s) > 0 {
			*out[i] = Atoi(s) != 0
		}
	}
	return true
}
func (is IniSection) readI32ForStage(name string, out ...*int32) bool {
	str := is[name]
	if len(str) == 0 {
		return false
	}
	for i, s := range strings.Split(str, ",") {
		if i >= len(out) {
			break
		}
		if s = strings.TrimLeftFunc(s, unicode.IsSpace); len(s) > 0 {
			*out[i] = Atoi(s)
		}
		if strings.IndexFunc(s, unicode.IsSpace) >= 0 {
			break
		}
	}
	return true
}
func (is IniSection) readF32ForStage(name string, out ...*float32) bool {
	str := is[name]
	if len(str) == 0 {
		return false
	}
	for i, s := range strings.Split(str, ",") {
		if i >= len(out) {
			break
		}
		if s = strings.TrimLeftFunc(s, unicode.IsSpace); len(s) > 0 {
			*out[i] = float32(Atof(s))
		}
		if strings.IndexFunc(s, unicode.IsSpace) >= 0 {
			break
		}
	}
	return true
}
func (is IniSection) readI32CsvForStage(name string) (ary []int32) {
	if str := is[name]; len(str) > 0 {
		for _, s := range strings.Split(str, ",") {
			if s = strings.TrimLeftFunc(s, unicode.IsSpace); len(s) > 0 {
				ary = append(ary, Atoi(s))
			}
			if strings.IndexFunc(s, unicode.IsSpace) >= 0 {
				break
			}
		}
	}
	return
}
func (is IniSection) getText(name string) (str string, ok bool, err error) {
	str, ok = is[name]
	if !ok {
		return
	}
	if len(str) < 2 || str[0] != '"' || str[len(str)-1] != '"' {
		return "", false, Error("\"で囲まれていません")
	}
	str = str[1 : len(str)-1]
	return
}
func (is IniSection) getString(name string) (str string, ok bool) {
	str, ok = is[name]
	if !ok {
		return
	}
	if len(str) >= 2 && str[0] == '"' && str[len(str)-1] == '"' {
		str = str[1 : len(str)-1]
	}
	return
}

type Layout struct {
	offset  [2]float32
	facing  int8
	vfacing int8
	layerno int16
	scale   [2]float32
}

func newLayout(ln int16) *Layout {
	return &Layout{facing: 1, vfacing: 1, layerno: ln, scale: [...]float32{1, 1}}
}
func ReadLayout(pre string, is IniSection, ln int16) *Layout {
	l := newLayout(ln)
	l.Read(pre, is)
	return l
}
func (l *Layout) Read(pre string, is IniSection) {
	is.ReadF32(pre+"offset", &l.offset[0], &l.offset[1])
	if str := is[pre+"facing"]; len(str) > 0 {
		if Atoi(str) < 0 {
			l.facing = -1
		} else {
			l.facing = 1
		}
	}
	if str := is[pre+"vfacing"]; len(str) > 0 {
		if Atoi(str) < 0 {
			l.vfacing = -1
		} else {
			l.vfacing = 1
		}
	}
	ln := int32(l.layerno)
	is.ReadI32(pre+"layerno", &ln)
	l.layerno = I32ToI16(Min(2, ln))
	is.ReadF32(pre+"scale", &l.scale[0], &l.scale[1])
}
func (l *Layout) DrawSprite(x, y float32, ln int16, s *Sprite, fx *PalFX, fscale float32, window *[4]int32) {
	if l.layerno == ln && s != nil {
		/*if l.facing < 0 {
			//x += sys.lifebarFontScale
		}
		if l.vfacing < 0 {
			//y += sys.lifebarFontScale
		}*/
		paltex := s.PalTex
		s.Draw(x+l.offset[0], y+l.offset[1],
			l.scale[0]*float32(l.facing)*fscale, l.scale[1]*float32(l.vfacing)*fscale, s.Pal, fx, paltex, window, true)
	}
}
func (l *Layout) DrawAnim(r *[4]int32, x, y, scl float32, ln int16,
	a *Animation, palfx *PalFX) {
	if l.layerno == ln {
		/*if l.facing < 0 {
			//x += sys.lifebarFontScale
		}
		if l.vfacing < 0 {
			//y += sys.lifebarFontScale
		}*/
		a.Draw(r, x+l.offset[0], y+l.offset[1]+float32(sys.gameHeight-240),
			scl, scl, l.scale[0]*float32(l.facing), l.scale[0]*float32(l.facing),
			l.scale[1]*float32(l.vfacing),
			0, 0, 0, 0, float32(sys.gameWidth-320)/2, palfx, false, 1, false, 1)
	}
}
func (l *Layout) DrawText(x, y, scl float32, ln int16,
	text string, f *Fnt, b, a int32, palfx *PalFX) {
	if l.layerno == ln {
		/*if l.facing < 0 {
			//x += sys.lifebarFontScale
		}
		if l.vfacing < 0 {
			//y += sys.lifebarFontScale
		}*/
		f.Print(text, (x+l.offset[0])*scl, (y+l.offset[1])*scl,
			l.scale[0]*sys.lifebarFontScale*float32(l.facing)*scl,
			l.scale[1]*sys.lifebarFontScale*float32(l.vfacing)*scl, b, a,
			&sys.scrrect, palfx)
	}
}

type AnimLayout struct {
	anim  Animation
	lay   Layout
	palfx *PalFX
}

func newAnimLayout(sff *Sff, ln int16) *AnimLayout {
	return &AnimLayout{anim: *newAnimation(sff), lay: *newLayout(ln), palfx: newPalFX()}
}
func ReadAnimLayout(pre string, is IniSection,
	sff *Sff, at AnimationTable, ln int16) *AnimLayout {
	al := newAnimLayout(sff, ln)
	al.Read(pre, is, at, ln)
	return al
}
func (al *AnimLayout) Read(pre string, is IniSection, at AnimationTable,
	ln int16) {
	var g, n int32
	if is.ReadI32(pre+"spr", &g, &n) {
		al.anim.frames = []AnimFrame{*newAnimFrame()}
		al.anim.frames[0].Group, al.anim.frames[0].Number =
			I32ToI16(g), I32ToI16(n)
		al.anim.mask = 0
		al.lay = *newLayout(ln)
	}
	if is.ReadI32(pre+"anim", &n) {
		if ani := at.get(n); ani != nil {
			al.anim = *ani
			al.lay = *newLayout(ln)
		}
	}
	al.ReadAnimPalfx(pre+"palfx.", is)
	al.lay.Read(pre, is)
}
func (al *AnimLayout) Reset() {
	al.anim.Reset()
}
func (al *AnimLayout) Action() {
	if al.palfx != nil {
		al.palfx.step()
	}
	al.anim.Action()
}
func (al *AnimLayout) Draw(x, y float32, layerno int16) {
	al.lay.DrawAnim(&sys.scrrect, x, y, 1, layerno, &al.anim, al.palfx)
}

// DrawScaled allows to set a custom scale with the draw (For lifebar localcoord)
func (al *AnimLayout) DrawScaled(x, y float32, layerno int16, scale float32) {
	al.lay.DrawAnim(&sys.scrrect, x, y, scale, layerno, &al.anim, al.palfx)
}

func (al *AnimLayout) ReadAnimPalfx(pre string, is IniSection) {
	al.palfx.clear()
	al.palfx.time = -1
	is.ReadI32(pre+"time", &al.palfx.time)
	is.ReadI32(pre+"add", &al.palfx.add[0], &al.palfx.add[1], &al.palfx.add[2])
	is.ReadI32(pre+"mul", &al.palfx.mul[0], &al.palfx.mul[1], &al.palfx.mul[2])
	is.ReadI32(pre+"sinadd", &al.palfx.sinadd[0], &al.palfx.sinadd[1], &al.palfx.sinadd[2], &al.palfx.cycletime)
	is.ReadBool(pre+"invertall", &al.palfx.invertall)
	var n float32
	if is.ReadF32(pre+"color", &n) {
		al.palfx.color = MaxF(0, MinF(1, n/256))
	}
}

type AnimTextSnd struct {
	snd         [2]int32
	text        LbText
	anim        AnimLayout
	displaytime int32
	//time        int32
	//sndtime     int32
}

func newAnimTextSnd(sff *Sff, ln int16) *AnimTextSnd {
	return &AnimTextSnd{snd: [2]int32{-1},
		anim: *newAnimLayout(sff, ln), displaytime: -2}
}
func ReadAnimTextSnd(pre string, is IniSection,
	sff *Sff, at AnimationTable, ln int16, f []*Fnt) *AnimTextSnd {
	ats := newAnimTextSnd(sff, ln)
	ats.Read(pre, is, at, ln, f)
	return ats
}
func (ats *AnimTextSnd) Read(pre string, is IniSection, at AnimationTable,
	ln int16, f []*Fnt) {
	is.ReadI32(pre+"snd", &ats.snd[0], &ats.snd[1])
	ats.text = *readLbText(pre, is, "", ln, f, 0)
	ats.anim.lay = *newLayout(ln)
	ats.anim.Read(pre, is, at, ln)
	is.ReadI32(pre+"displaytime", &ats.displaytime)
}
func (ats *AnimTextSnd) Reset()  { ats.anim.Reset() }
func (ats *AnimTextSnd) Action() { ats.anim.Action() }

func (ats *AnimTextSnd) Draw(x, y float32, layerno int16, f []*Fnt) {
	if len(ats.anim.anim.frames) > 0 {
		ats.anim.Draw(x, y, layerno)
	} else if ats.text.font[0] >= 0 && int(ats.text.font[0]) < len(f) &&
		len(ats.text.text) > 0 {
		ats.text.lay.DrawText(x, y, 1, layerno, ats.text.text,
			f[ats.text.font[0]], ats.text.font[1], ats.text.font[2], ats.text.palfx)
	}
}

// DrawScaled it's Draw but with a scaled setting used for lifebar localcoord
func (ats *AnimTextSnd) DrawScaled(x, y float32, layerno int16, f []*Fnt, scale float32) {
	if len(ats.anim.anim.frames) > 0 {
		ats.anim.DrawScaled(x, y, layerno, scale)
	} else if ats.text.font[0] >= 0 && int(ats.text.font[0]) < len(f) &&
		len(ats.text.text) > 0 {
		ats.text.lay.DrawText(x, y, scale, layerno, ats.text.text,
			f[ats.text.font[0]], ats.text.font[1], ats.text.font[2], ats.text.palfx)
	}
}

func (ats *AnimTextSnd) NoSound() bool { return ats.snd[0] < 0 }
func (ats *AnimTextSnd) NoDisplay() bool {
	return len(ats.anim.anim.frames) == 0 &&
		(ats.text.font[0] < 0 || len(ats.text.text) == 0)
}
func (ats *AnimTextSnd) End(dt int32) bool {
	if ats.displaytime < 0 {
		return len(ats.anim.anim.frames) == 0 || ats.anim.anim.loopend ||
			(ats.anim.anim.frames[ats.anim.anim.current].Time == -1 && ats.anim.anim.current == int32(len(ats.anim.anim.frames)-1))
	}
	return dt >= ats.displaytime
}
