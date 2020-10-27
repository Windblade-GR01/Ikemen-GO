package main

import (
	"encoding/binary"
	"os"
	"regexp"
	"strings"

	"github.com/Windblade-GR01/glfont"
	findfont "github.com/flopp/go-findfont"
)

// FntCharImage stores sprite and position
type FntCharImage struct {
	ofs, w uint16
	img    []Sprite
}

// Fnt is a interface for basic font information
type Fnt struct {
	images    map[rune]*FntCharImage
	palettes  [][256]uint32
	ver, ver2 uint16
	Type      string
	Size      [2]uint16
	Spacing   [2]int32
	colors    int32
	offset    [2]int32
	ttf       *glfont.Font
	palfx     *PalFX
	//alphaSrc  int32
	//alphaDst  int32
	PalName   string
}

func newFnt() *Fnt {
	return &Fnt{
		images: make(map[rune]*FntCharImage),
		palfx:  newPalFX(),
	}
}

func loadFnt(filename string, height int32) (*Fnt, error) {

	if strings.HasSuffix(filename, ".fnt") {
		return loadFntV1(filename)
	}

	return loadFntV2(filename, height)
}

func loadFntV1(filename string) (*Fnt, error) {
	f := newFnt()

	filename = SearchFile(filename, "font/")

	fp, err := os.Open(filename)

	f.PalName = filename

	if err != nil {
		return nil, err
	}

	defer func() { chk(fp.Close()) }()

	//Read header
	buf := make([]byte, 12)
	n, err := fp.Read(buf)

	//Error reading file
	if err != nil {
		return nil, err
	}

	//Error is not a valid fnt file
	if string(buf[:n]) != "ElecbyteFnt\x00" {
		return nil, Error("ElecbyteFntではありません")
	}

	read := func(x interface{}) error {
		return binary.Read(fp, binary.LittleEndian, x)
	}

	if err := read(&f.ver); err != nil {
		return nil, err
	}

	if err := read(&f.ver2); err != nil {
		return nil, err
	}

	var pcxDataOffset, pcxDataLenght, txtDataOffset, txtDataLenght uint32
	if err := read(&pcxDataOffset); err != nil {
		return nil, err
	}

	if err := read(&pcxDataLenght); err != nil {
		return nil, err
	}

	if err := read(&txtDataOffset); err != nil {
		return nil, err
	}

	if err := read(&txtDataLenght); err != nil {
		return nil, err
	}

	spr := newSprite()
	if err := spr.readPcxHeader(fp, int64(pcxDataOffset)); err != nil {
		return nil, err
	}

	fp.Seek(int64(pcxDataOffset)+128, 0)
	px := make([]byte, pcxDataLenght-128-768)
	if err := read(px); err != nil {
		return nil, err
	}

	spr.Pal = make([]uint32, 256)
	var rgb [3]byte
	for i := range spr.Pal {
		if err := read(rgb[:]); err != nil {
			return nil, err
		}
		spr.Pal[i] = uint32(rgb[2])<<16 | uint32(rgb[1])<<8 | uint32(rgb[0])
	}

	px = spr.RlePcxDecode(px)
	fp.Seek(int64(txtDataOffset), 0)
	buf = make([]byte, txtDataLenght)
	if err := read(buf); err != nil {
		return nil, err
	}
	lines := SplitAndTrim(string(buf), "\n")
	i := 0
	mapflg, defflg := true, true
	for {
		var name string
		for ; i < len(lines); i++ {
			name, _ = SectionName(lines[i])
			if len(name) > 0 {
				i++
				break
			}
		}
		if len(name) == 0 {
			break
		}
		switch name {
		case "map":
			if mapflg {
				mapflg = false
				re := regexp.MustCompile(`(\S+)(?:\s+(\S+)(?:\s+(\S+))?)?`)
				ofs := uint16(0)
				w := int32(0)
				for ; i < len(lines); i++ {
					if len(lines[i]) > 0 && lines[i][0] == '[' {
						break
					}
					cap := re.FindStringSubmatch(strings.SplitN(lines[i], ";", 2)[0])
					if len(cap) > 0 {
						var c rune
						if len(cap[1]) >= 2 && cap[1][0] == '0' &&
							(cap[1][1] == 'X' || cap[1][1] == 'x') {
							hex := strings.ToLower(cap[1][2:])
							for _, r := range hex {
								if '0' <= r && r <= '9' {
									c = c<<4 | (r - '0')
								} else if 'a' <= r && r <= 'f' {
									c = c<<4 | (r - 'a' + 10)
								} else {
									break
								}
							}
						} else {
							c = rune(cap[1][0])
						}
						if len(cap[2]) > 0 {
							ofs = I32ToU16(Atoi(cap[2]))
						}
						fci := &FntCharImage{ofs: ofs}
						f.images[c] = fci
						if len(cap[3]) > 0 {
							w = Atoi(cap[3])
							if w < 0 {
								ofs += I32ToU16(int32(ofs) - w)
								w = 0 - w
							}
							fci.w = I32ToU16(w)
							ofs += fci.w - f.Size[0]
						} else {
							fci.w = f.Size[0]
						}
					}
					ofs += f.Size[0]
				}
			}
		case "def":
			if defflg {
				defflg = false
				is := NewIniSection()
				is.Parse(lines, &i)
				loadDefInfo(f, filename, is, 0)
			}
		}
	}
	f.palettes = make([][256]uint32, 255/f.colors)
	for i := int32(0); int(i) < len(f.palettes); i++ {
		copy(f.palettes[i][:256-f.colors], spr.Pal[:256-f.colors])
		copy(f.palettes[i][256-f.colors:],
			spr.Pal[256-f.colors*(i+1):256-f.colors*i])
	}
	copyCharRect := func(dst []byte, dw int, src []byte, x, w, h int) {
		dw2 := dw
		if x+dw > w {
			dw2 = w - x
		}
		if dw2 > 0 {
			for i := 0; i < h; i++ {
				copy(dst[dw*i:dw*i+dw2], src[w*i+x:w*i+x+dw2])
			}
		}
	}
	for _, fci := range f.images {
		fci.img = make([]Sprite, len(f.palettes))
		for i, p := range f.palettes {
			if i == 0 {
				fci.img[0].shareCopy(spr)
				fci.img[0].Size[0] = fci.w
				px2 := make([]byte, int(fci.w)*int(fci.img[0].Size[1]))
				copyCharRect(px2, int(fci.w), px, int(fci.ofs),
					int(spr.Size[0]), int(spr.Size[1]))
				fci.img[0].SetPxl(px2)
			} else {
				i, fci := i, fci
				sys.mainThreadTask <- func() {
					fci.img[i].shareCopy(&fci.img[0])
					fci.img[i].Size[0] = fci.w
				}
			}
			fci.img[i].Offset[0], fci.img[i].Offset[1], fci.img[i].Pal = 0, 0, p[:]
		}
	}

	f.palfx.setColor(255, 255, 255)

	return f, nil
}

func loadFntV2(filename string, height int32) (*Fnt, error) {
	f := newFnt()

	filename = SearchFile(filename, "font/")

	content, err := LoadText(filename)

	f.PalName = filename

	if err != nil {
		return nil, err
	}

	lines := SplitAndTrim(string(content), "\n")
	i := 0
	var name string

	for ; i < len(lines); i++ {
		name, _ = SectionName(lines[i])
		if len(name) > 0 {
			is := NewIniSection()
			i++
			is.Parse(lines, &i)
			i--
			switch name {
			case "def":
				loadDefInfo(f, filename, is, height)
			}
		}
	}

	f.palfx.setColor(255, 255, 255)

	return f, nil
}

func loadDefInfo(f *Fnt, filename string, is IniSection, height int32) {
	f.Type = strings.ToLower(is["type"])
	ary := SplitAndTrim(is["size"], ",")
	if len(ary[0]) > 0 {
		f.Size[0] = I32ToU16(Atoi(ary[0]))
	}
	if len(ary) > 1 && len(ary[1]) > 0 {
		f.Size[1] = I32ToU16(Atoi(ary[1]))
	}
	ary = SplitAndTrim(is["spacing"], ",")
	if len(ary[0]) > 0 {
		f.Spacing[0] = Atoi(ary[0])
	}
	if len(ary) > 1 && len(ary[1]) > 0 {
		f.Spacing[1] = Atoi(ary[1])
	}
	f.colors = Atoi(is["colors"])
	if f.colors > 255 {
		f.colors = 255
	} else if f.colors < 1 {
		f.colors = 1
	}
	ary = SplitAndTrim(is["offset"], ",")
	if len(ary[0]) > 0 {
		f.offset[0] = Atoi(ary[0])
	}
	if len(ary) > 1 && len(ary[1]) > 0 {
		f.offset[1] = Atoi(ary[1])
	}

	if len(is["file"]) > 0 {
		if f.Type == "truetype" {
			loadFntTtf(f, filename, is["file"], height)
		} else {
			loadFntSff(f, filename, is["file"])
		}
	}
}

func loadFntTtf(f *Fnt, fontfile string, filename string, height int32) {
	//Search in local directory
	fileDir := SearchFile(filename, fontfile)
	//Search in system directory
	fp := fileDir
	if fp = FileExist(fp); len(fp) == 0 {
		var err error
		fileDir, err = findfont.Find(fileDir)
		if err != nil {
			panic(err)
		}
	}
	//Load ttf
	if height == -1 {
		height = int32(f.Size[1])
	} else {
		f.Size[1] = uint16(height)
	}
	glfont.FontShaderVer = "#version " + sys.fontShaderVer
	ttf, err := glfont.LoadFont(fileDir, height, int(sys.gameWidth), int(sys.gameHeight))
	if err != nil {
		panic(err)
	}
	f.ttf = ttf

	//Create Ttf dummy palettes
	f.palettes = make([][256]uint32, 1)
	for i := 0; i < 256; i++ {
		f.palettes[0][i] = 0
	}
}

func loadFntSff(f *Fnt, fontfile string, filename string) {
	fileDir := SearchFile(filename, fontfile)
	sff, err := loadSff(fileDir, false)

	if err != nil {
		err = nil
		sff, err = loadSff(fileDir, false)
	}

	if err != nil {
		panic(err)
	}

	//Load sprites
	for k, sprite := range sff.sprites {
		s := sff.getOwnPalSprite(sprite.Group, sprite.Number)
		if sprite.Group == 0 {
			offsetX := uint16(s.Offset[0])
			sizeX := uint16(s.Size[0])

			fci := &FntCharImage{
				ofs: offsetX,
				w:   sizeX,
			}
			fci.img = make([]Sprite, 1)
			fci.img[0] = *s
			f.images[rune(k[1])] = fci
		}
	}

	//Load palettes
	f.palettes = make([][256]uint32, sff.header.NumberOfPalettes)
	var idef int
	for i := 0; i < int(sff.header.NumberOfPalettes); i++ {
		var pal []uint32
		si, ok := sff.palList.PalTable[[...]int16{0, int16(i)}]
		if ok && si >= 0 {
			pal = sff.palList.Get(si)
			if i == 0 {
				idef = si
			}
		} else {
			pal = sff.palList.Get(idef)
		}
		copy(f.palettes[i][:], pal)
	}
}

//CharWidth returns the width that has a specified character
func (f *Fnt) CharWidth(c rune) int32 {
	if c == ' ' {
		return int32(f.Size[0])
	}
	fci := f.images[c]
	if fci == nil {
		return 0
	}
	return int32(fci.w)
}

//TextWidth returns the width that has a specified text.
//This depends on each char's width and font spacing
func (f *Fnt) TextWidth(txt string) (w int32) {
	for _, c := range txt {
		if f.Type == "truetype" {
			w += int32(f.ttf.Width(1, string(c)))
		} else {
			w += f.CharWidth(c) + f.Spacing[0]
		}
	}
	return
}

func (f *Fnt) getCharSpr(c rune, bank int32) *Sprite {
	fci := f.images[c]
	if fci == nil {
		return nil
	}

	if bank < int32(len(fci.img)) {
		return &fci.img[bank]
	}

	return &fci.img[0]
}

/*func (f *Fnt) calculateTrans() int32 {
	alphaSrc := int32(sys.brightness * f.alphaSrc >> 8)
	separator := int32(1 << 9)
	alphaDst := int32(f.alphaDst << 10)

	return alphaSrc | separator | alphaDst
}*/

func (f *Fnt) drawChar(x, y, xscl, yscl float32, bank int32, c rune,
	pal []uint32, window *[4]int32, absolute bool) float32 {

	if c == ' ' {
		return float32(f.Size[0]) * xscl
	}

	spr := f.getCharSpr(c, bank)
	if spr == nil || spr.Tex == nil {
		return 0
	}

	//trans := f.calculateTrans()

	//spr.Draw(x, y, xscl, yscl, pal, nil, nil, window)
	x -= xscl * float32(spr.Offset[0])
	y -= yscl * float32(spr.Offset[1])
	if absolute {
		spr.glDraw(pal, 0, -x,
			-y, &notiling, xscl, xscl,
			yscl, 0, 0, 0, 0,
			sys.brightness*255>>8|1<<9, window, 0, 0, nil, nil)
	} else {
		spr.glDraw(pal, 0, -x*sys.widthScale,
			-y*sys.heightScale, &notiling, xscl*sys.widthScale, xscl*sys.widthScale,
			yscl*sys.heightScale, 0, 0, 0, 0,
			sys.brightness*255>>8|1<<9, window, 0, 0, nil, nil)
	}

	//if pal != nil {
	//	RenderMugenPal(*spr.Tex, 0, spr.Size, -x*sys.widthScale,
	//		-y*sys.heightScale, &notiling, xscl*sys.widthScale, xscl*sys.widthScale,
	//		yscl*sys.heightScale, 1, 0, 0, 0, 0, sys.brightness*255>>8|1<<9, &sys.scrrect,
	//		0, 0, false, 1, &[3]float32{0, 0, 0}, &[3]float32{1, 1, 1})
	//} else {
	//	RenderMugenFc(*spr.Tex, spr.Size, -x*sys.widthScale,
	//		-y*sys.heightScale, &notiling, xscl*sys.widthScale, xscl*sys.widthScale,
	//		yscl*sys.heightScale, 1, 0, 0, 0, 0, sys.brightness*255>>8|1<<9, &sys.scrrect,
	//		0, 0, false, 1, &[3]float32{0, 0, 0}, &[3]float32{1, 1, 1})
	//}

	return float32(spr.Size[0]) * xscl
}

func (f *Fnt) Print(txt string, x, y, xscl, yscl float32, bank, align int32,
	window *[4]int32, palfx *PalFX) {
	if !sys.frameSkip {
		if f.Type == "truetype" {
			f.DrawTtf(txt, x, y, xscl, yscl, align, false, window, palfx.frgba, false)
		} else {
			f.DrawText(txt, x, y, xscl, yscl, bank, align, window, palfx, false)
		}
	}
}

//DrawText prints on screen a specified text with the current font sprites
func (f *Fnt) DrawText(txt string, x, y, xscl, yscl float32, bank, align int32,
	window *[4]int32, palfx *PalFX, absolute bool) {

	if len(txt) == 0 {
		return
	}

	x += float32(f.offset[0])*xscl
	y += float32(f.offset[1]-int32(f.Size[1])+1)*yscl
	if !absolute {
		x += float32(sys.gameWidth-320)/2
		y += float32(sys.gameHeight-240)
	}

	if align == 0 {
		x -= float32(f.TextWidth(txt)) * xscl * 0.5
	} else if align < 0 {
		x -= float32(f.TextWidth(txt)) * xscl
	}

	if bank < 0 || len(f.palettes) <= int(bank) {
		bank = 0
	}

	var pal []uint32
	//var paltex uint32
	if len(f.palettes) != 0 {
		pal = palfx.getFxPal(f.palettes[bank][:], false)
		//gl.Enable(gl.TEXTURE_1D)
		//gl.ActiveTexture(gl.TEXTURE1)
		//gl.GenTextures(1, &paltex)
		//gl.BindTexture(gl.TEXTURE_1D, paltex)
		//gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
		//gl.TexImage1D(
		//	gl.TEXTURE_1D,
		//	0,
		//	gl.RGBA,
		//	256,
		//	0,
		//	gl.RGBA,
		//	gl.UNSIGNED_BYTE,
		//	unsafe.Pointer(&pal[0]),
		//)
		//gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
		//gl.TexParameteri(gl.TEXTURE_1D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	}

	for _, c := range txt {
		x += f.drawChar(x, y, xscl, yscl, bank, c, pal, window, absolute) + xscl*float32(f.Spacing[0])
	}
	//gl.DeleteTextures(1, &paltex)
	//gl.Disable(gl.TEXTURE_1D)
}

func (f *Fnt) DrawTtf(txt string, x, y, xscl, yscl float32, align int32,
	blend bool, window *[4]int32, frgba [4]float32, absolute bool) {

	if len(txt) == 0 {
		return
	}

	x += float32(f.offset[0])*xscl
	if !absolute {
		x += float32(sys.gameWidth-320)/2
	}
	//y += float32(f.offset[1]-int32(f.Size[1])+1)*yscl + float32(sys.gameHeight-240)

	win := [4]int32{(*window)[0], sys.scrrect[3] - ((*window)[1] + (*window)[3]),
		(*window)[2], (*window)[3]}

	f.ttf.SetColor(frgba[0], frgba[1], frgba[2], frgba[3])    //r, g, b, a
	f.ttf.Printf(x, y, (xscl+yscl)/2, align, blend, win, txt) //x, y, scale, align, blend, window, string, printf args
}

type TextSprite struct {
	text             string
	fnt              *Fnt
	bank, align      int32
	x, y, xscl, yscl float32
	window           [4]int32
	palfx            *PalFX
}

func NewTextSprite() *TextSprite {
	return &TextSprite{align: 1, xscl: 1, yscl: 1, window: sys.scrrect, palfx: newPalFX()}
}

func (ts *TextSprite) SetWindow(x, y, w, h float32, absolute bool) {
	if absolute {
		ts.window[0] = int32(x)
		ts.window[1] = int32(y)
		ts.window[2] = int32(w + 0.5)
		ts.window[3] = int32(h + 0.5)
	} else {
		ts.window[0] = int32((x + float32(sys.gameWidth-320)/2) * sys.widthScale)
		ts.window[1] = int32((y + float32(sys.gameHeight-240)) * sys.heightScale)
		ts.window[2] = int32(w*sys.widthScale + 0.5)
		ts.window[3] = int32(h*sys.heightScale + 0.5)
	}
}

func (ts *TextSprite) Draw(absolute bool) {
	if !sys.frameSkip && ts.fnt != nil {
		if ts.fnt.Type == "truetype" {
			ts.fnt.DrawTtf(ts.text, ts.x, ts.y, ts.xscl, ts.yscl, ts.align, true, &ts.window, ts.palfx.frgba, absolute)
		} else {
			ts.fnt.DrawText(ts.text, ts.x, ts.y, ts.xscl, ts.yscl, ts.bank, ts.align, &ts.window, ts.palfx, absolute)
		}
	}
}
