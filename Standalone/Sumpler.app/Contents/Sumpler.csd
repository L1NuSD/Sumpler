<Cabbage> bounds(0, 0, 0, 0)
form caption("Sumpler") size(500, 350), guiMode("queue"), pluginId("def1")
image bounds(-16, -18, 550, 600) channel("background") file("Space.png")

groupbox bounds(90, 160, 210, 122)  text("Bit") textColour(225, 255, 255, 255) colour(0, 0, 0, 0)
groupbox bounds(90, 32, 210, 122)  text("Sample") textColour(225, 255, 255, 255) colour(0, 0, 0, 0)
groupbox bounds(306, 134, 178, 145)  text("Reverb") textColour(225, 255, 255, 255) colour(0, 0, 0, 0)

button bounds(12, 30, 69, 56) channel("PlayStop1") colour:1(42, 74, 255, 255) colour:0(55, 106, 132, 255) text("Play", "Stop")
combobox   bounds(308, 30, 74, 24), channel("FFTSize"), , value(9), text("32768", "16384", "8192", "4096", "2048", "1024", "512", "256", "128", "64", "32", "16", "8", "4")
rslider bounds(102, 64, 60, 64) channel("Transpose") range(0, 1, 0, 1, 0.001) text("pitch") textColour(255, 255, 255, 225)
rslider bounds(162, 64, 60, 64) channel("speed") range(0, 1, 0, 1, 0.001) text("speed") textColour(255, 255, 255, 225)
rslider bounds(222, 64, 60, 64) channel("level") range(0, 1, 0, 1, 0.001) text("level") textColour(255, 255, 255, 225)
combobox bounds(10, 100, 74, 19) channel("File") text("Shells.wav", "Grill.wav", "Water", "Draining", "Paper", "Keychain"))

rslider bounds(226, 188, 60, 64), text("Bits"),     channel("bits"),  range(1, 16, 16, 1, 0.001),        textColour(225, 255, 255, 255),    
rslider bounds(164, 188, 60, 64), text("Foldover"), channel("fold"),  range(1, 1024, 0, 0.25, 0.001), textColour(225, 255, 255, 255),    
rslider bounds(104, 188, 60, 64), text("BLevel"),    channel("blevel"), range(0, 1, 1, 1, 0.001),       textColour(225, 255, 255, 255),    

rslider bounds(334, 216, 57, 49),  text("Mix")      channel("verbMix"),     range(0, 1, 0.3, 1, 0.001), textColour(225, 255, 255, 255)
rslider bounds(404, 216, 58, 49),  text("Feed")       channel("feed"),     range(0, 1, 0.5, 1, 0.001), textColour(225, 255, 255, 255)
rslider bounds(364, 156, 58, 48),  text("Filter")      channel("verbFilter"),     range(0, 20000, 20000, 1, 0.001), textColour(225, 255, 255, 255)

combobox bounds(72, 284, 100, 25), populate("*.snaps"), channelType("string") automatable(0) channel("combo11") value("0")
filebutton bounds(8, 286, 60, 25), text("Save", "Save"), populate("*.snaps", "test"), mode("named preset") channel("filebutton12")
filebutton bounds(10, 318, 60, 25), text("Remove", "Remove"), populate("*.snaps", "test"), mode("remove preset") channel("filebutton15")

label bounds(388, 32, 76, 21) channel("label10017") text("FFT") 


label bounds(10, 128, 80, 16) channel("label10020") text("Choose")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
ksmps = 32
nchnls = 2
0dbfs = 1

giFFTSizes[]    array    32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4   
garvb init 0

;From the Lofi effect by Iain McCurdy, 2012
;http://iainmccurdy.org/csound.html
opcode  LoFi,a,akk
    ain,kbits,kfold xin                                 ; READ IN INPUT ARGUMENTS
    kvalues pow     2, kbits                            ; RAISES 2 TO THE POWER OF kbitdepth. THE OUTPUT VALUE REPRESENTS THE NUMBER OF POSSIBLE VALUES AT THAT PARTICULAR BIT DEPTH
    aout    =       (int((ain/0dbfs)*kvalues))/kvalues  ; BIT DEPTH REDUCE AUDIO SIGNAL
    aout    fold    aout, kfold                         ; APPLY SAMPLING RATE FOLDOVER
            xout    aout                                ; SEND AUDIO BACK TO CALLER INSTRUMENT
endop

  
//SAMPLE #1
//======================================


instr 1
gkPlayStop1 chnget "PlayStop1"

 if gkPlayStop1==0 then
turnoff
 endif
 
gkTab1   chnget "File"
gktranspose1    chnget    "Transpose"
gklevel1        chnget    "level"
gkFFTSize1    chnget    "FFTSize"
gkspeed1    chnget      "speed"

kporttime    linseg    0,0.001,0.05
ktranspose1    portk    gktranspose1,kporttime



  ktrig    changed        gkFFTSize1
  if ktrig==1 then
   reinit RESTART
  endif
 
 kbits     chnget  "bits"
kfold     chnget  "fold"
klevel    chnget  "blevel"
kporttime linseg  0, 0.001, 0.01
kfold     portk   kfold, kporttime 
    
    RESTART:
asigL1, asigR1   temposcal gkspeed1, gklevel1, semitone(ktranspose1), gkTab1, 1, giFFTSizes[i(gkFFTSize1)-1]
asigL LoFi asigL1, kbits * 0.6, kfold
asigR LoFi asigR1, kbits * 0.6, kfold       

kverbSend chnget "verbMix"

outs asigL, asigR

garvb = garvb + asigL

endin

instr 2

ipitchMod = 0

    kfeed        chnget    "feed"
    kverbfilt    chnget    "verbFilter"

arvb1, arvb2  reverbsc garvb, garvb, kfeed, kverbfilt, sr, ipitchMod
		outs		arvb1, arvb2

	garvb	=		0

endin


instr 99

gkPlayStop1 chnget "PlayStop1"
ktrig1    trigger    gkPlayStop1,0.5,0      
schedkwhen    ktrig1,0,0,1,0,-1    

endin
    


    


</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f 1 0 0 1 "Shells.wav" 0 4 0
f 2 0 0 1 "Grill.wav" 0 4 0
f 3 0 0 1 "Water.wav" 0 4 0
f 4 0 0 1 "Draining.wav" 0 4 0
f 5 0 0 1 "Paper.wav" 0 4 0
f 5 0 0 1 "Keychain.wav" 0 4 0

f0 z

i 99 0 10000
i 2 0 10000
</CsScore>
</CsoundSynthesizer>
