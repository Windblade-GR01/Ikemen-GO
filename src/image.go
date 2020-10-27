package main

import (
	"encoding/binary"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"io"
	"math"
	"os"
	"runtime"
	"unsafe"

	"github.com/go-gl/gl/v2.1/gl"
)

type TransType int32

const (
	TT_default TransType = iota
	TT_none
	TT_add
	TT_alpha
	TT_add1
	TT_sub
)

type Texture uint32

func newTexture() (t *Texture) {
	t = new(Texture)
	gl.GenTextures(1, (*uint32)(t))
	runtime.SetFinalizer(t, (*Texture).finalizer)
	return
}
func (t *Texture) finalizer() {
	if *t != 0 {
		tex := *t
		sys.mainThreadTask <- func() {
			gl.DeleteTextures(1, (*uint32)(&tex))
		}
	}
}

type PalFXDef struct {
	time      int32
	color     float32
	add       [3]int32
	mul       [3]int32
	sinadd    [3]int32
	cycletime int32
	invertall bool
	frgba     [4]float32
}
type PalFX struct {
	PalFXDef
	remap      []int
	negType    bool
	sintime    int32
	enable     bool
	eNegType   bool
	eInvertall bool
	eAdd       [3]int32
	eMul       [3]int32
	eColor     float32
}

func newPalFX() *PalFX { return &PalFX{} }
func (pf *PalFX) clear2(nt bool) {
	pf.PalFXDef = PalFXDef{color: 1, mul: [...]int32{256, 256, 256},
		frgba: [...]float32{1.0, 1.0, 1.0, 1.0}}
	pf.negType = nt
	pf.sintime = 0
}
func (pf *PalFX) clear() {
	pf.clear2(false)
}
func (pf *PalFX) getSynFx() *PalFX {
	if pf == nil || !pf.enable {
		return &sys.allPalFX
	}
	if !sys.allPalFX.enable {
		return pf
	}
	synth := *pf
	synth.synthesize(sys.allPalFX)
	return &synth
}
func (pf *PalFX) getFxPal(pal []uint32, neg bool) []uint32 {
	p := pf.getSynFx()
	if !p.enable {
		return pal
	}
	if !p.eNegType {
		neg = false
	}
	var m [3]int32
	if neg {
		for i := range m {
			m[i] = (p.eMul[(i+1)%3] + p.eMul[(i+2)%3]) >> 1
		}
	} else {
		m = p.eMul
	}
	a, sub := p.eAdd, uint32(0)
	for i := range a {
		if neg {
			a[i] *= -1
		}
		su := uint32(0)
		if a[i] < 0 {
			su = uint32(-Max(-255, a[i]))
			a[i] = 0
		}
		m[i] = Max(0, Min(255*256, m[i]))
		a[i] = Min(255*256*256/Max(1, m[i]), a[i])
		sub |= su << uint(i*8)
	}
	for i, c := range pal {
		if p.eInvertall {
			c = ^c
		}
		ac := float32(c&0xff+c>>8&0xff+c>>16&0xff) / 3
		c = uint32(float32(c&0xff)+(ac-float32(c&0xff))*(1-p.eColor)) |
			uint32(float32(c>>8&0xff)+(ac-float32(c>>8&0xff))*(1-p.eColor))<<8 |
			uint32(float32(c>>16&0xff)+(ac-float32(c>>16&0xff))*(1-p.eColor))<<16
		tmp := ((^c&sub)<<1 + (^c^sub)&0xfefefefe) & 0x01010100
		c = (c - sub + tmp) & ^(tmp - tmp>>8)
		tmp = (c&0xff + uint32(a[0])) * uint32(m[0]) >> 8
		tmp = (tmp|uint32(-Btoi(tmp&0xff00 != 0)))&0xff |
			(((c>>8&0xff)+uint32(a[1]))*uint32(m[1])>>8)<<8
		tmp = (tmp|uint32(-Btoi(tmp&0xff0000 != 0)<<8))&0xffff |
			(((c>>16&0xff)+uint32(a[2]))*uint32(m[2])>>8)<<16
		sys.workpal[i] = tmp | uint32(-Btoi(tmp&0xff000000 != 0)<<16) |
			0xff000000
	}
	return sys.workpal
}
func (pf *PalFX) getFcPalFx(transNeg bool) (neg bool, color float32,
	add, mul [3]float32) {
	p := pf.getSynFx()
	if !p.enable {
		neg = false
		color = 1
		for i := range add {
			add[i] = 0
		}
		for i := range mul {
			mul[i] = 1
		}
		return
	}
	neg = p.eInvertall
	color = p.eColor
	if !p.eNegType {
		transNeg = false
	}
	for i, v := range p.eAdd {
		add[i] = float32(v) / 255
		if transNeg {
			add[i] *= -1
			mul[i] = float32(p.eMul[(i+1)%3]+p.eMul[(i+2)%3]) / 512
		} else {
			mul[i] = float32(p.eMul[i]) / 256
		}
	}
	return
}
func (pf *PalFX) sinAdd(color *[3]int32) {
	if pf.cycletime > 1 {
		st := 2 * math.Pi * float64(pf.sintime)
		if pf.cycletime == 2 {
			st += math.Pi / 2
		}
		sin := math.Sin(st / float64(pf.cycletime))
		for i := range *color {
			(*color)[i] += int32(sin * float64(pf.sinadd[i]))
		}
	}
}
func (pf *PalFX) step() {
	pf.enable = pf.time != 0
	if pf.enable {
		pf.eMul = pf.mul
		pf.eAdd = pf.add
		pf.eColor = pf.color
		pf.eInvertall = pf.invertall
		pf.eNegType = pf.negType
		pf.sinAdd(&pf.eAdd)
		if pf.cycletime > 0 {
			pf.sintime = (pf.sintime + 1) % pf.cycletime
		}
		if pf.time > 0 {
			pf.time--
		}
	}
}
func (pf *PalFX) synthesize(pfx PalFX) {
	for i, m := range pfx.eMul {
		pf.eMul[i] = pf.eMul[i] * m / 256
	}
	for i, a := range pfx.eAdd {
		pf.eAdd[i] += a
	}
	pf.eColor *= pfx.eColor
	pf.eInvertall = pf.eInvertall != pfx.eInvertall
}

func (pf *PalFX) setColor(r, g, b float32) {
	rNormalized := Max(0, Min(255, int32(r)))
	gNormalized := Max(0, Min(255, int32(g)))
	bNormalized := Max(0, Min(255, int32(b)))

	pf.enable = true
	pf.eColor = 1
	pf.eMul = [...]int32{
		256 * rNormalized >> 8,
		256 * gNormalized >> 8,
		256 * bNormalized >> 8,
	}

	pf.frgba = [...]float32{float32(rNormalized) / 255, float32(gNormalized) / 255,
		float32(bNormalized) / 255, 1.0}
}

type PaletteList struct {
	palettes   [][]uint32
	paletteMap []int
	PalTable   map[[2]int16]int
	PalTex     []*Texture
}

func (pl *PaletteList) init() {
	pl.palettes = nil
	pl.paletteMap = nil
	pl.PalTable = make(map[[2]int16]int)
	pl.PalTex = nil
}
func (pl *PaletteList) SetSource(i int, p []uint32) {
	if i < len(pl.paletteMap) {
		pl.paletteMap[i] = i
	} else {
		for i > len(pl.paletteMap) {
			pl.paletteMap = append(pl.paletteMap, len(pl.paletteMap))
		}
		pl.paletteMap = append(pl.paletteMap, i)
	}
	if i < len(pl.palettes) {
		pl.palettes[i] = p
	} else {
		for i > len(pl.palettes) {
			pl.palettes = append(pl.palettes, nil)
		}
		pl.palettes = append(pl.palettes, p)
		pl.PalTex = append(pl.PalTex, nil)
	}
}
func (pl *PaletteList) NewPal() (i int, p []uint32) {
	i, p = len(pl.palettes), make([]uint32, 256)
	pl.SetSource(i, p)
	return
}
func (pl *PaletteList) Get(i int) []uint32 {
	return pl.palettes[pl.paletteMap[i]]
}
func (pl *PaletteList) Remap(source int, destination int) {
	pl.paletteMap[source] = destination
}
func (pl *PaletteList) ResetRemap() {
	for i := range pl.paletteMap {
		pl.paletteMap[i] = i
	}
}
func (pl *PaletteList) GetPalMap() []int {
	pm := make([]int, len(pl.paletteMap))
	copy(pm, pl.paletteMap)
	return pm
}
func (pl *PaletteList) SwapPalMap(palMap *[]int) bool {
	if len(*palMap) != len(pl.paletteMap) {
		return false
	}
	*palMap, pl.paletteMap = pl.paletteMap, *palMap
	return true
}

type SffHeader struct {
	Ver0, Ver1, Ver2, Ver3   byte
	FirstSpriteHeaderOffset  uint32
	FirstPaletteHeaderOffset uint32
	NumberOfSprites          uint32
	NumberOfPalettes         uint32
}

func (sh *SffHeader) Read(r io.Reader, lofs *uint32, tofs *uint32) error {
	buf := make([]byte, 12)
	n, err := r.Read(buf)
	if err != nil {
		return err
	}
	if string(buf[:n]) != "ElecbyteSpr\x00" {
		return Error("ElecbyteSprではありません")
	}
	read := func(x interface{}) error {
		return binary.Read(r, binary.LittleEndian, x)
	}
	if err := read(&sh.Ver3); err != nil {
		return err
	}
	if err := read(&sh.Ver2); err != nil {
		return err
	}
	if err := read(&sh.Ver1); err != nil {
		return err
	}
	if err := read(&sh.Ver0); err != nil {
		return err
	}
	var dummy uint32
	if err := read(&dummy); err != nil {
		return err
	}
	switch sh.Ver0 {
	case 1:
		sh.FirstPaletteHeaderOffset, sh.NumberOfPalettes = 0, 0
		if err := read(&sh.NumberOfSprites); err != nil {
			return err
		}
		if err := read(&sh.FirstSpriteHeaderOffset); err != nil {
			return err
		}
		if err := read(&dummy); err != nil {
			return err
		}
	case 2:
		for i := 0; i < 4; i++ {
			if err := read(&dummy); err != nil {
				return err
			}
		}
		if err := read(&sh.FirstSpriteHeaderOffset); err != nil {
			return err
		}
		if err := read(&sh.NumberOfSprites); err != nil {
			return err
		}
		if err := read(&sh.FirstPaletteHeaderOffset); err != nil {
			return err
		}
		if err := read(&sh.NumberOfPalettes); err != nil {
			return err
		}
		if err := read(lofs); err != nil {
			return err
		}
		if err := read(&dummy); err != nil {
			return err
		}
		if err := read(tofs); err != nil {
			return err
		}
	default:
		return Error("バージョンが不正です")
	}
	return nil
}

type Sprite struct {
	Pal           []uint32
	Tex           *Texture
	Group, Number int16
	Size          [2]uint16
	Offset        [2]int16
	palidx        int
	rle           int
	paltemp       []uint32
	PalTex        *Texture
}

func newSprite() *Sprite {
	return &Sprite{palidx: -1}
}
func selectablePalettes(filename string) ([]int32, error) {
	var pal []int32
	f, err := os.Open(filename)
	if err != nil {
		return pal, err
	}
	defer func() { chk(f.Close()) }()
	h := &SffHeader{}
	var lofs, tofs uint32
	if err := h.Read(f, &lofs, &tofs); err != nil {
		return pal, err
	}
	read := func(x interface{}) error {
		return binary.Read(f, binary.LittleEndian, x)
	}
	if h.Ver0 != 1 {
		for i := 0; i < int(h.NumberOfPalettes); i++ {
			f.Seek(int64(h.FirstPaletteHeaderOffset)+int64(i*16), 0)
			var gn_ [3]int16
			if err := read(gn_[:]); err != nil {
				return pal, err
			}
			if gn_[0] == 1 && gn_[1] <= MaxPalNo {
				pal = append(pal, int32(gn_[1]))
			}
		}
	}
	return pal, err
}
func loadFromSff(filename string, g, n int16) (*Sprite, error) {
	s := newSprite()
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer func() { chk(f.Close()) }()
	h := &SffHeader{}
	var lofs, tofs uint32
	if err := h.Read(f, &lofs, &tofs); err != nil {
		return nil, err
	}
	var shofs, xofs, size uint32 = h.FirstSpriteHeaderOffset, 0, 0
	var indexOfPrevious uint16
	pl := &PaletteList{}
	pl.init()
	foo := func() error {
		switch h.Ver0 {
		case 1:
			if err := s.readHeader(f, &xofs, &size, &indexOfPrevious); err != nil {
				return err
			}
		case 2:
			if err := s.readHeaderV2(f, &xofs, &size,
				lofs, tofs, &indexOfPrevious); err != nil {
				return err
			}
		}
		return nil
	}
	var dummy *Sprite
	var newSubHeaderOffset []uint32
	newSubHeaderOffset = append(newSubHeaderOffset, shofs)
	i := 0
	for ; i < int(h.NumberOfSprites); i++ {
		newSubHeaderOffset = append(newSubHeaderOffset, shofs)
		f.Seek(int64(shofs), 0)
		if err := foo(); err != nil {
			return nil, err
		}
		if s.palidx < 0 || s.Group == g && s.Number == n {
			ip := len(newSubHeaderOffset)
			for size == 0 {
				if int(indexOfPrevious) >= ip {
					return nil, Error("linkが不正です")
				}
				ip = int(indexOfPrevious)
				if h.Ver0 == 1 {
					shofs = newSubHeaderOffset[ip]
				} else {
					shofs = h.FirstSpriteHeaderOffset + uint32(ip)*28
				}
				f.Seek(int64(shofs), 0)
				if err := foo(); err != nil {
					return nil, err
				}
			}
			switch h.Ver0 {
			case 1:
				if err := s.read(f, h, int64(shofs+32), size, xofs, dummy,
					pl, false); err != nil {
					return nil, err
				}
			case 2:
				if err := s.readV2(f, int64(xofs), size); err != nil {
					return nil, err
				}
			}
			if s.Group == g && s.Number == n {
				break
			}
			dummy = &Sprite{palidx: s.palidx}
		}
		if h.Ver0 == 1 {
			shofs = xofs
		} else {
			shofs += 28
		}
	}
	if i == int(h.NumberOfSprites) {
		return nil, Error(fmt.Sprintf("%v, %v のスプライトが見つかりません", g, n))
	}
	if h.Ver0 == 1 {
		s.Pal = pl.Get(s.palidx)
		s.palidx = -1
		return s, nil
	}
	if s.rle > -11 {
		read := func(x interface{}) error {
			return binary.Read(f, binary.LittleEndian, x)
		}
		size = 0
		indexOfPrevious = uint16(s.palidx)
		ip := indexOfPrevious + 1
		for size == 0 && ip != indexOfPrevious {
			ip = indexOfPrevious
			shofs = h.FirstPaletteHeaderOffset + uint32(ip)*16
			f.Seek(int64(shofs)+6, 0)
			if err := read(&indexOfPrevious); err != nil {
				return nil, err
			}
			if err := read(&xofs); err != nil {
				return nil, err
			}
			if err := read(&size); err != nil {
				return nil, err
			}
		}
		f.Seek(int64(lofs+xofs), 0)
		s.Pal = make([]uint32, 256)
		var rgba [4]byte
		for i := 0; i < int(size)/4 && i < len(s.Pal); i++ {
			if err := read(rgba[:]); err != nil {
				return nil, err
			}
			if h.Ver2 == 0 {
				rgba[3] = 255
			}
			s.Pal[i] = uint32(rgba[3])<<24 | uint32(rgba[2])<<16 | uint32(rgba[1])<<8 | uint32(rgba[0])
		}
		s.palidx = -1
	}
	return s, nil
}
func (s *Sprite) shareCopy(src *Sprite) {
	s.Pal = src.Pal
	s.Tex = src.Tex
	s.Size = src.Size
	if s.palidx < 0 {
		s.palidx = src.palidx
	}
	s.rle = src.rle
	//s.paltemp = src.paltemp
	//s.PalTex = src.PalTex
}
func (s *Sprite) GetPal(pl *PaletteList) []uint32 {
	if s.Pal != nil || s.rle <= -11 {
		return s.Pal
	}
	return pl.Get(int(s.palidx)) //pl.palettes[pl.paletteMap[int(s.palidx)]]
}
func (s *Sprite) GetPalTex(pl *PaletteList) *Texture {
	if s.rle <= -11 {
		return nil
	}

	return pl.PalTex[pl.paletteMap[int(s.palidx)]]
}
func (s *Sprite) SetPxl(px []byte) {
	if len(px) == 0 {
		return
	}
	if int64(len(px)) != int64(s.Size[0])*int64(s.Size[1]) {
		return
	}
	sys.mainThreadTask <- func() {
		gl.Enable(gl.TEXTURE_2D)
		s.Tex = newTexture()
		gl.BindTexture(gl.TEXTURE_2D, uint32(*s.Tex))
		gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE,
			int32(s.Size[0]), int32(s.Size[1]),
			0, gl.LUMINANCE, gl.UNSIGNED_BYTE, unsafe.Pointer(&px[0]))
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP)
		gl.Disable(gl.TEXTURE_2D)
	}
}
func (s *Sprite) readHeader(r io.Reader, ofs, size *uint32,
	link *uint16) error {
	read := func(x interface{}) error {
		return binary.Read(r, binary.LittleEndian, x)
	}
	if err := read(ofs); err != nil {
		return err
	}
	if err := read(size); err != nil {
		return err
	}
	if err := read(s.Offset[:]); err != nil {
		return err
	}
	if err := read(&s.Group); err != nil {
		return err
	}
	if err := read(&s.Number); err != nil {
		return err
	}
	if err := read(link); err != nil {
		return err
	}
	return nil
}
func (s *Sprite) readPcxHeader(f *os.File, offset int64) error {
	f.Seek(offset, 0)
	read := func(x interface{}) error {
		return binary.Read(f, binary.LittleEndian, x)
	}
	var dummy uint16
	if err := read(&dummy); err != nil {
		return err
	}
	var encoding, bpp byte
	if err := read(&encoding); err != nil {
		return err
	}
	if err := read(&bpp); err != nil {
		return err
	}
	if bpp != 8 {
		return Error("256色でありません")
	}
	var rect [4]uint16
	if err := read(rect[:]); err != nil {
		return err
	}
	f.Seek(offset+66, 0)
	var bpl uint16
	if err := read(&bpl); err != nil {
		return err
	}
	s.Size[0] = rect[2] - rect[0] + 1
	s.Size[1] = rect[3] - rect[1] + 1
	if encoding == 1 {
		s.rle = int(bpl)
	} else {
		s.rle = 0
	}
	return nil
}
func (s *Sprite) RlePcxDecode(rle []byte) (p []byte) {
	if len(rle) == 0 || s.rle <= 0 {
		return rle
	}
	p = make([]byte, int(s.Size[0])*int(s.Size[1]))
	i, j, k, w := 0, 0, 0, int(s.Size[0])
	for j < len(p) {
		n, d := 1, rle[i]
		if i < len(rle)-1 {
			i++
		}
		if d >= 0xc0 {
			n = int(d & 0x3f)
			d = rle[i]
			if i < len(rle)-1 {
				i++
			}
		}
		for ; n > 0; n-- {
			if k < w && j < len(p) {
				p[j] = d
				j++
			}
			k++
			if k == s.rle {
				k = 0
				n = 1
			}
		}
	}
	s.rle = 0
	return
}
func (s *Sprite) read(f *os.File, sh *SffHeader, offset int64, datasize uint32,
	nextSubheader uint32, prev *Sprite, pl *PaletteList, c00 bool) error {
	if int64(nextSubheader) > offset {
		// 最後以外datasizeを無視
		datasize = nextSubheader - uint32(offset)
	}
	read := func(x interface{}) error {
		return binary.Read(f, binary.LittleEndian, x)
	}
	var ps byte
	if err := read(&ps); err != nil {
		return err
	}
	paletteSame := ps != 0 && prev != nil
	if err := s.readPcxHeader(f, offset); err != nil {
		return err
	}
	f.Seek(offset+128, 0)
	var palSize uint32
	if c00 || paletteSame {
		palSize = 0
	} else {
		palSize = 768
	}
	if datasize < 128+palSize {
		datasize = 128 + palSize
	}
	px := make([]byte, datasize-(128+palSize))
	if err := read(px); err != nil {
		return err
	}
	if paletteSame {
		if prev != nil {
			s.palidx = prev.palidx
		}
		if s.palidx < 0 {
			s.palidx, _ = pl.NewPal()
		}
	} else {
		var pal []uint32
		s.palidx, pal = pl.NewPal()
		if c00 {
			f.Seek(offset+int64(datasize)-768, 0)
		}
		var rgb [3]byte
		for i := range pal {
			if err := read(rgb[:]); err != nil {
				return err
			}
			pal[i] = uint32(255)<<24 | uint32(rgb[2])<<16 | uint32(rgb[1])<<8 | uint32(rgb[0])
		}
	}
	s.SetPxl(s.RlePcxDecode(px))
	return nil
}
func (s *Sprite) readHeaderV2(r io.Reader, ofs *uint32, size *uint32,
	lofs uint32, tofs uint32, link *uint16) error {
	read := func(x interface{}) error {
		return binary.Read(r, binary.LittleEndian, x)
	}
	if err := read(&s.Group); err != nil {
		return err
	}
	if err := read(&s.Number); err != nil {
		return err
	}
	if err := read(s.Size[:]); err != nil {
		return err
	}
	if err := read(s.Offset[:]); err != nil {
		return err
	}
	if err := read(link); err != nil {
		return err
	}
	var format byte
	if err := read(&format); err != nil {
		return err
	}
	s.rle = -int(format)
	var dummy byte
	if err := read(&dummy); err != nil {
		return err
	}
	if err := read(ofs); err != nil {
		return err
	}
	if err := read(size); err != nil {
		return err
	}
	var tmp uint16
	if err := read(&tmp); err != nil {
		return err
	}
	s.palidx = int(tmp)
	if err := read(&tmp); err != nil {
		return err
	}
	if tmp&1 == 0 {
		*ofs += lofs
	} else {
		*ofs += tofs
	}
	return nil
}
func (s *Sprite) Rle8Decode(rle []byte) (p []byte) {
	if len(rle) == 0 {
		return rle
	}
	p = make([]byte, int(s.Size[0])*int(s.Size[1]))
	i, j := 0, 0
	for j < len(p) {
		n, d := 1, rle[i]
		if i < len(rle)-1 {
			i++
		}
		if d&0xc0 == 0x40 {
			n = int(d & 0x3f)
			d = rle[i]
			if i < len(rle)-1 {
				i++
			}
		}
		for ; n > 0; n-- {
			if j < len(p) {
				p[j] = d
				j++
			}
		}
	}
	return
}
func (s *Sprite) Rle5Decode(rle []byte) (p []byte) {
	if len(rle) == 0 {
		return rle
	}
	p = make([]byte, int(s.Size[0])*int(s.Size[1]))
	i, j := 0, 0
	for j < len(p) {
		rl := int(rle[i])
		if i < len(rle)-1 {
			i++
		}
		dl := int(rle[i] & 0x7f)
		c := byte(0)
		if rle[i]>>7 != 0 {
			if i < len(rle)-1 {
				i++
			}
			c = rle[i]
		}
		if i < len(rle)-1 {
			i++
		}
		for {
			if j < len(p) {
				p[j] = c
				j++
			}
			rl--
			if rl < 0 {
				dl--
				if dl < 0 {
					break
				}
				c = rle[i] & 0x1f
				rl = int(rle[i] >> 5)
				if i < len(rle)-1 {
					i++
				}
			}
		}
	}
	return
}
func (s *Sprite) Lz5Decode(rle []byte) (p []byte) {
	if len(rle) == 0 {
		return rle
	}
	p = make([]byte, int(s.Size[0])*int(s.Size[1]))
	i, j, n := 0, 0, 0
	ct, cts, rb, rbc := rle[i], uint(0), byte(0), uint(0)
	if i < len(rle)-1 {
		i++
	}
	for j < len(p) {
		d := int(rle[i])
		if i < len(rle)-1 {
			i++
		}
		if ct&byte(1<<cts) != 0 {
			if d&0x3f == 0 {
				d = (d<<2 | int(rle[i])) + 1
				if i < len(rle)-1 {
					i++
				}
				n = int(rle[i]) + 2
				if i < len(rle)-1 {
					i++
				}
			} else {
				rb |= byte(d & 0xc0 >> rbc)
				rbc += 2
				n = int(d & 0x3f)
				if rbc < 8 {
					d = int(rle[i]) + 1
					if i < len(rle)-1 {
						i++
					}
				} else {
					d = int(rb) + 1
					rb, rbc = 0, 0
				}
			}
			for {
				if j < len(p) {
					p[j] = p[j-d]
					j++
				}
				n--
				if n < 0 {
					break
				}
			}
		} else {
			if d&0xe0 == 0 {
				n = int(rle[i]) + 8
				if i < len(rle)-1 {
					i++
				}
			} else {
				n = d >> 5
				d &= 0x1f
			}
			for ; n > 0; n-- {
				if j < len(p) {
					p[j] = byte(d)
					j++
				}
			}
		}
		cts++
		if cts >= 8 {
			ct, cts = rle[i], 0
			if i < len(rle)-1 {
				i++
			}
		}
	}
	return
}
func (s *Sprite) readV2(f *os.File, offset int64, datasize uint32) error {
	f.Seek(offset+4, 0)
	if s.rle < 0 {
		format := -s.rle
		var px []byte
		if 2 <= format && format <= 4 {
			if datasize < 4 {
				datasize = 4
			}
			px = make([]byte, datasize-4)
			if err := binary.Read(f, binary.LittleEndian, px); err != nil {
				panic(err)
				//return err
			}
		}
		switch format {
		case 2:
			px = s.Rle8Decode(px)
		case 3:
			px = s.Rle5Decode(px)
		case 4:
			px = s.Lz5Decode(px)
		case 10:
			img, err := png.Decode(f)
			if err != nil {
				return err
			}
			pi, ok := img.(*image.Paletted)
			if ok {
				px = pi.Pix
			}
		case 11, 12:
			img, err := png.Decode(f)
			if err != nil {
				return err
			}
			rect := img.Bounds()
			rgba, ok := img.(*image.RGBA)
			if !ok {
				rgba = image.NewRGBA(rect)
				draw.Draw(rgba, rect, img, rect.Min, draw.Src)
			}
			sys.mainThreadTask <- func() {
				gl.Enable(gl.TEXTURE_2D)
				s.Tex = newTexture()
				gl.BindTexture(gl.TEXTURE_2D, uint32(*s.Tex))
				gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
				gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, int32(rect.Max.X-rect.Min.X),
					int32(rect.Max.Y-rect.Min.Y), 0, gl.RGBA, gl.UNSIGNED_BYTE,
					unsafe.Pointer(&rgba.Pix[0]))
				gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
				gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
				gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
				gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
				gl.Disable(gl.TEXTURE_2D)
			}
			return nil
		default:
			return Error("不明な形式です")
		}
		s.SetPxl(px)
	}
	return nil
}
func (s *Sprite) glDraw(pal []uint32, mask int32, x, y float32, tile *[4]int32,
	xts, xbs, ys, rxadd, agl, yagl, xagl float32, trans int32, window *[4]int32,
	rcx, rcy float32, pfx *PalFX, paltex *Texture) {
	if s.Tex == nil {
		return
	}
	neg, color, padd, pmul := pfx.getFcPalFx(trans == -2)
	if trans == -2 {
		padd[0] *= -1
		padd[1] *= -1
		padd[2] *= -1
	}

	if s.rle <= -11 {
		RenderMugenFc(*s.Tex, s.Size, x, y, tile, xts, xbs, ys, 1, rxadd, agl, yagl, xagl,
			trans, window, rcx, rcy, neg, color, &padd, &pmul)
	} else {
		//読み込み済みパレットの情報が渡されてるか
		if paltex != nil {
			gl.ActiveTexture(gl.TEXTURE1)
			gl.BindTexture(gl.TEXTURE_1D, uint32(*paltex))
			RenderMugenPal(*s.Tex, mask, s.Size, x, y, tile, xts, xbs, ys, 1,
				rxadd, agl, yagl, xagl, trans, window, rcx, rcy, neg, color, &padd, &pmul)
			gl.Disable(gl.TEXTURE_1D)
			return
		}
		//無い場合暫定の方法でパレットテクスチャ生成
		PalEqual := true
		if len(pal) != len(s.paltemp) {
			PalEqual = false
		} else {
			for i := range pal {
				if pal[i] != s.paltemp[i] {
					PalEqual = false
					break
				}
			}
		}
		if PalEqual {
			if s.PalTex == nil {
				return
			}
			gl.ActiveTexture(gl.TEXTURE1)
			gl.BindTexture(gl.TEXTURE_1D, uint32(*s.PalTex))
			RenderMugenPal(*s.Tex, mask, s.Size, x, y, tile, xts, xbs, ys, 1,
				rxadd, agl, yagl, xagl, trans, window, rcx, rcy, neg, color, &padd, &pmul)
			gl.Disable(gl.TEXTURE_1D)
		} else {
			gl.Enable(gl.TEXTURE_1D)
			gl.ActiveTexture(gl.TEXTURE1)
			s.PalTex = newTexture()
			gl.BindTexture(gl.TEXTURE_1D, uint32(*s.PalTex))
			gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
			gl.TexImage1D(gl.TEXTURE_1D, 0, gl.RGBA, 256, 0, gl.RGBA, gl.UNSIGNED_BYTE,
				unsafe.Pointer(&pal[0]))
			gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
			gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
			tmp := append([]uint32{}, pal...)
			s.paltemp = tmp
			RenderMugenPal(*s.Tex, mask, s.Size, x, y, tile, xts, xbs, ys, 1,
				rxadd, agl, yagl, xagl, trans, window, rcx, rcy, neg, color, &padd, &pmul)
			gl.Disable(gl.TEXTURE_1D)
		}
	}
}
func (s *Sprite) Draw(x, y, xscale, yscale float32, pal []uint32, fx *PalFX, paltex *Texture, window *[4]int32, scale bool) {
	if scale {
		x += float32(sys.gameWidth-320)/2 - xscale*float32(s.Offset[0])
		y += float32(sys.gameHeight-240) - yscale*float32(s.Offset[1])
	}
	if xscale < 0 {
		x *= -1
	}
	if yscale < 0 {
		y *= -1
	}
	if scale {
		s.glDraw(pal, 0, -x*sys.widthScale, -y*sys.heightScale, &notiling,
			xscale*sys.widthScale, xscale*sys.widthScale, yscale*sys.heightScale, 0, 0, 0, 0,
			sys.brightness*255>>8|1<<9, window, 0, 0, fx, paltex)
	} else {
		s.glDraw(pal, 0, -x, -y, &notiling,
			xscale, xscale, yscale, 0, 0, 0, 0,
			sys.brightness*255>>8|1<<9, window, 0, 0, fx, paltex)
	}
}

type Sff struct {
	header  SffHeader
	sprites map[[2]int16]*Sprite
	palList PaletteList
}

func newSff() (s *Sff) {
	s = &Sff{sprites: make(map[[2]int16]*Sprite)}
	s.palList.init()
	for i := int16(1); i <= int16(MaxPalNo); i++ {
		s.palList.PalTable[[...]int16{1, i}], _ = s.palList.NewPal()
	}
	return
}
func loadSff(filename string, char bool) (*Sff, error) {
	s := newSff()
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer func() { chk(f.Close()) }()
	var lofs, tofs uint32
	if err := s.header.Read(f, &lofs, &tofs); err != nil {
		return nil, err
	}
	read := func(x interface{}) error {
		return binary.Read(f, binary.LittleEndian, x)
	}
	if s.header.Ver0 != 1 {
		var uniquePals map[[2]int16]bool = make(map[[2]int16]bool)
		for i := 0; i < int(s.header.NumberOfPalettes); i++ {
			f.Seek(int64(s.header.FirstPaletteHeaderOffset)+int64(i*16), 0)
			var gn_ [3]int16
			if err := read(gn_[:]); err != nil {
				return nil, err
			}
			if uniquePals[[...]int16{gn_[0], gn_[1]}] {
				sys.warnConsole(fmt.Sprintf("WARNING: %v duplicated palette: %v,%v (%v/%v)\n", filename, gn_[0], gn_[1], i+1, s.header.NumberOfPalettes))
				sys.errLog.Printf("%v duplicated palette: %v,%v (%v/%v)\n", filename, gn_[0], gn_[1], i+1, s.header.NumberOfPalettes)
			} else {
				uniquePals[[...]int16{gn_[0], gn_[1]}] = true
			}
			var link uint16
			if err := read(&link); err != nil {
				return nil, err
			}
			var ofs, siz uint32
			if err := read(&ofs); err != nil {
				return nil, err
			}
			if err := read(&siz); err != nil {
				return nil, err
			}
			var pal []uint32
			var idx int
			if siz == 0 {
				idx = int(link)
				pal = s.palList.Get(idx)
			} else {
				f.Seek(int64(lofs+ofs), 0)
				pal = make([]uint32, 256)
				var rgba [4]byte
				for i := 0; i < int(siz)/4 && i < len(pal); i++ {
					if err := read(rgba[:]); err != nil {
						return nil, err
					}
					if s.header.Ver2 == 0 {
						rgba[3] = 255
					}
					pal[i] = uint32(rgba[3])<<24 | uint32(rgba[2])<<16 | uint32(rgba[1])<<8 | uint32(rgba[0])
				}
				idx = i
			}
			s.palList.SetSource(i, pal)
			s.palList.PalTable[[...]int16{gn_[0], gn_[1]}] = idx
			if i <= MaxPalNo &&
				s.palList.PalTable[[...]int16{1, int16(i + 1)}] == s.palList.PalTable[[...]int16{gn_[0], gn_[1]}] &&
				gn_[0] != 1 && gn_[1] != int16(i+1) {
				s.palList.PalTable[[...]int16{1, int16(i + 1)}] = -1
			}
			if i <= MaxPalNo && i+1 == int(s.header.NumberOfPalettes) {
				for j := i + 1; j < MaxPalNo; j++ {
					delete(s.palList.PalTable, [...]int16{1, int16(j + 1)}) //余計なパレットを削除
				}
			}
		}
	}
	spriteList := make([]*Sprite, int(s.header.NumberOfSprites))
	var prev *Sprite
	shofs := int64(s.header.FirstSpriteHeaderOffset)
	for i := 0; i < len(spriteList); i++ {
		f.Seek(shofs, 0)
		spriteList[i] = newSprite()
		var xofs, size uint32
		var indexOfPrevious uint16
		switch s.header.Ver0 {
		case 1:
			if err := spriteList[i].readHeader(f, &xofs, &size,
				&indexOfPrevious); err != nil {
				return nil, err
			}
		case 2:
			if err := spriteList[i].readHeaderV2(f, &xofs, &size,
				lofs, tofs, &indexOfPrevious); err != nil {
				return nil, err
			}
		}
		if size == 0 {
			if int(indexOfPrevious) < i {
				dst, src := spriteList[i], spriteList[int(indexOfPrevious)]
				sys.mainThreadTask <- func() {
					dst.shareCopy(src)
				}
			} else {
				spriteList[i].palidx = 0 // 不正な sff の場合の index out of range 防止
			}
		} else {
			switch s.header.Ver0 {
			case 1:
				if err := spriteList[i].read(f, &s.header, shofs+32, size,
					xofs, prev, &s.palList,
					char && (prev == nil || spriteList[i].Group == 0 &&
						spriteList[i].Number == 0)); err != nil {
					return nil, err
				}
			case 2:
				if err := spriteList[i].readV2(f, int64(xofs), size); err != nil {
					return nil, err
				}
			}
			prev = spriteList[i]
		}
		if s.sprites[[...]int16{spriteList[i].Group, spriteList[i].Number}] ==
			nil {
			s.sprites[[...]int16{spriteList[i].Group, spriteList[i].Number}] =
				spriteList[i]
		}
		if s.header.Ver0 == 1 {
			shofs = int64(xofs)
		} else {
			shofs += 28
		}
	}
	//パレットテクスチャ生成
	sys.mainThreadTask <- func() {
		for i, v := range s.palList.palettes {
			gl.Enable(gl.TEXTURE_1D)
			s.palList.PalTex[i] = newTexture()
			gl.BindTexture(gl.TEXTURE_1D, uint32(*s.palList.PalTex[i]))
			gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
			gl.TexImage1D(gl.TEXTURE_1D, 0, gl.RGBA, 256, 0, gl.RGBA, gl.UNSIGNED_BYTE,
				unsafe.Pointer(&v[0]))
			gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
			gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
			gl.Disable(gl.TEXTURE_1D)
		}
	}
	return s, nil
}
func (s *Sff) GetSprite(g, n int16) *Sprite {
	if g == -1 {
		return nil
	}
	return s.sprites[[...]int16{g, n}]
}
func (s *Sff) getOwnPalSprite(g, n int16) *Sprite {
	sys.runMainThreadTask() // テクスチャを生成
	sp := s.GetSprite(g, n)
	if sp == nil {
		return nil
	}
	osp, pal := *sp, sp.GetPal(&s.palList)
	osp.Pal = make([]uint32, len(pal))
	copy(osp.Pal, pal)
	return &osp
}
func captureScreen() {
	width, height := sys.window.Window.GetSize()
	pixdata := make([]uint8, 4*width*height)
	img := image.NewNRGBA(image.Rect(0, 0, width, height))
	unbindFB()
	gl.ReadPixels(0, 0, int32(width), int32(height), gl.RGBA, gl.UNSIGNED_BYTE, gl.Ptr(pixdata))
	for i := 0; i < 4*width*height; i++ {
		var x, y, j int
		x = i % (width * 4)
		y = i / (width * 4)
		j = x + (height-1-y)*width*4
		if i%4 == 3 {
			pixdata[i] = 255 //アルファ値を255にする
		}
		img.Pix[j] = pixdata[i]
	}
	var filename string
	for i := sys.captureNum; i < 999; i++ {
		if i < 10 {
			filename = fmt.Sprintf("ikemen00%d.png", i)
		} else if i < 100 {
			filename = fmt.Sprintf("ikemen0%d.png", i)
		} else {
			filename = fmt.Sprintf("ikemen%d.png", i)
		}
		if _, err := os.Stat(filename); os.IsNotExist(err) {
			file, _ := os.Create(sys.screenshotFolder + filename)
			defer file.Close()
			png.Encode(file, img)
			sys.captureNum = i
			break
		}
	}
}
