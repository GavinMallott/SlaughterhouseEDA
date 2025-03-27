const std = @import("std");

//Scales
const k: f64 = 1e3;
const M: f64 = 1e6;
const G: f64 = 1e9;
const T: f64 = 1e12;
const P: f64 = 1e15;
const m: f64 = 1e-3;
const u: f64 = 1e-6;
const n: f64 = 1e-9;
const p: f64 = 1e-12;
const f: f64 = 1e-15;
pub fn c_from_k (kelvin: f64) f64 {
    return kelvin - 273;
}

pub const Net = struct {
    items: std.AutoHashMap(Component, u64),
    name: []const u8,

};

pub const Component = struct {
    comp_t: Element_t,



};

pub const Card_t = union(enum) {
    TITLE,
    COMMENT,
    END,
    SUBCKT,              //.SUBCKT subnam N1 <N2,N3,N4 ...>   ###   .SUBCKT OPAMP 1 2 3 4
    ELEMENT,
    MODEL,               //.MODEL MNAME TYPE(PNAME1=PVAL1 PNAME2=PVAL2 ... )   ###   .MODEL MOD1 NPN BF=50 IS=1E-13 VBF=50
    CONTROL,

};

pub const Card = struct {
    card_t: Card_t,
    card_id: []const u8 = "",
    arglist: [][]const u8 = [_][]const u8 {""},

};

pub const CommentCard = struct {
    id: []const u8 = "*",
    comment: []const u8 = "",

};

pub const EndCard = struct {
    id: []const u8 = ".END",
    subckt_end: bool = false,

};


pub const Signal_t = union(enum(u8)) {
    PULSE,                  //PULSE(V1 V2 TD TR TF PW PER)   ###   VIN 3 0 PULSE(-1 1 2NS 2NS 2NS 50NS 100NS)
    SIN,                    //SIN(VO VA FREQ TD THETA)   ###   VIN 3 0 SIN(0 1 100MEG 1NS 1E10)
    EXP,                    //EXP(V1 V2 TD1 TAU1 TD2 TAU2)   ###   VIN 3 0 EXP(-4 -1 2NS 30NS 60NS 40NS)
    PWL,                    //PWL(T1 V1 )   ###   VCLOCK 7 5 PWL(0 -7 10NS -7 11NS -3 17NS -3 18NS -7 50NS -7)
    SFFM,                   //SFFM(VO VA FC MDI FS)   ###   V1 12 0 SFFM(0 1M 20K 5 1K)

};

pub const Model_t = union(enum(u8)) {    
    D,
    NPN,
    PNP,
    NJF,
    PJF,
    NMOS,
    PMOS,

};

pub const Element_t = union(enum) {
    RESISTOR,               //RXXXXXXX N1 N2 VALUE <TC=TC1<,TC2>>   ###   RC1 12 17 1K TC=0.001,0.015
    CAPACITOR,              //CXXXXXXX N+ N- VALUE <IC=INCOND>   ###   COSC 17 23 10U IC=3V
    INDUCTOR,               //LXXXXXXX N+ N- VALUE <IC=INCOND>   ###   LSHUNT 23 51 10U IC=15.7MA
    COUPLED_INDUCTOR,       //KXXXXXXX LYYYYYYY LZZZZZZZ VALUE   ###   KXFRMR L1 L2 0.87
    TRANSMISSION_LINE,      //TXXXXXXX N1 N2 N3 N4 Z0=VALUE <TD=VALUE> <F=FREQ <NL=NRMLEN>>+<IC=V1,I1,V2,I2>   ###   T1 1 0 2 0 Z0=50 TD=10NS

    //Independant Sources (IS)
    VOLTAGE_SOURCE,         //VXXXXXXX N+ N- <<DC> DC/TRAN VALUE> <AC <ACMAG <ACPHASE>>>   ###   VIN 13 2 0.001 AC 1 SIN(0 1 1MEG)
    CURRENT_SOURCE,         //IYYYYYYY N+ N- <<DC> DC/TRAN VALUE> <AC <ACMAG <ACPHASE>>>   ###   ISRC 23 21 AC 0.333 45.0 SFFM(0 1 10K 5 1K)

    //Linear Dependant Sources (LDS)
    LVCCS,                  //GXXXXXXX N+ N- NC+ NC- VALUE   ###   G1 2 0 5 0 0.1MMHO
    LVCVS,                  //EXXXXXXX N+ N- NC+ NC- VALUE   ###   E1 2 3 14 1 2.0
    LCCCS,                  //FXXXXXXX N+ N- VNAM VALUE   ###   F1 13 5 VSENS 5
    LCCVS,                  //HXXXXXXX N+ N- VNAM VALUE   ###   HX 5 17 VZ 0.5K

    //Semiconductor Devices (SD) Requires .MODEL Card in Deck
    DIODE,                  //DXXXXXXX N+ N- MNAME <AREA> <OFF> <IC=VD>   ###   DCLMP 3 7 DMOD 3.0 IC=0.2
    BJT,                    //QXXXXXXX NC NB NE <NS> MNAME <AREA> <OFF> <IC=VBE,VCE>   ###   Q23 10 24 13 QMOD IC=0.6,5.0
    JFET,                   //JXXXXXXX ND NG NS MNAME <AREA> <OFF> <IC=VDS,VGS>   ###   J1 7 2 3 JM1 OFF
    MOSFET,                 //MXXXXXXX ND NG NS NB MNAME <L=VAL> <W=VAL> <AD=VAL> <AS=VAL> <PD=VAL> <PS=VAL> <NRD=VAL> <NRS=VAL> <OFF> <IC=VDS,VGS,VBS>

    //Subcircuit Call (SC) Requires .SUBCKT Definition in Deck
    SUBCKT,                 //XXXXXXXX N1 <N2,N3,N4...> SUBNAM   ###   X1 2 4 17 3 1 MULTI

};

pub const Control_t = union(enum(u8)) {
    TEMP,                   //.TEMP T1 <T2,T3,T4 ...>   ###   .TEMP -55.0 25.0 125.0
    WIDTH,                  //.WIDTH IN=COLNUM OUT=COLNUM   ###   .WIDTH IN=72 OUT=133
    OPTIONS,                //.OPTIONS OPT1 OPT2 ... (or OPT=OPTVAL ...)   ###   .OPTIONS ACCT LIST NODE
    OP,                     //.OP   ###   Force Determine DC Operating Point (Inductors shorted, Capacitors opened) Will be called automattically if no other analysis is called
    DC,                     //.DC SRCNAM VSTART VSTOP VINCR [SRC2 START2 STOP2 INCR2]   ###   .DC VCE 0 10 .25 IB 0 10U 1U   (DC Sweep requires at least one IS with DC Value)
    NODESET,                //.NODESET V(NODNUM)=VAL V(NODNUM)=VAL ...   ###   .NODESET V(12)=4.5 V(4)=2.23   (Sets Voltage or Current at specified node)
    IC,                     //.IC V(NODNUM)=VAL V(NODNUM)=VAL ...   ###   .IC V(11)=5 V(4)=-5 V(2)=2.2   (Transient Initial Conditions)
    TF,                     //.TF OUTVAR INSRC   ###   .TF V(5,3) VIN   (DC Small-Signal Transfer Function)
    SENS,                   //.SENS OV1 <OV2 ... >   ###   .SENS V(9) V(4,3) V(17) I(VCC)   (DC Small=Signal Sensitivity)
    AC,                     //.AC DEC ND FSTART FSTOP or .AC OCT NO FSTART FSTOP or .AC LIN NP FSTART FSTOP   (AC Analysis requires at least on IS with AC Value)
    DISTO,                  //.DISTO RLOAD <INTER <SKW2 <REFPWR <SPW2>>>>   ###   .DISTO RL 2 0.95 1.0E-3 0.75   (Compute Distortion)
    NOISE,                  //.NOISE OUTV INSRC NUMS   ###   .NOISE V(5) VIN 10   (Noise Analysis used with AC Card)
    TRAN,                   //.TRAN TSTEP TSTOP <TSTART <TMAX>> <UIC>   ###   .TRAN 1NS 1000NS 500NS   (Perform Transient Analysis)
    FOUR,                   //.FOUR FREQ OV1 <OV2 OV3 ...>   ###   .FOUR 100K  V(5)   (Perform Fourier Analysis w/ fundamental frequency and specified output variables)
    PRINT,                  //.PRINT PRTYPE OV1 <OV2 ... OV8>   ###   .PRINT DC V(2) I(VSRC) V(23,17)
    PLOT,                   //.PLOT PLTYPE OV1 <(PLO1,PHI1)> <OV2 <(PLO2,PHI2)> ... OV8>   ###   .PLOT AC VM(5) VM(31,24) VDB(5) VP(5)

};


pub const Option_t = struct {
    ACCT: bool = false,     // causes accounting and run time statistics to be printed
    LIST: bool = false,     // causes the summary listing of the input data to be printed
    NOMOD: bool = false,    // suppresses the printout of the model parameters
    NOPAGE: bool = false,   // suppresses page ejects
    NODE: bool = false,     // causes the printing of the node table
    OPTS: bool = false,     // causes the option values to be printed
    GMIN: f64 = 1e-12,      // resets the value of GMIN, the minimum conductance allowed by the program
    RELTOL: f64 = 0.001,    // resets the relative error tolerance of the program
    ABSTOL: f64 = 1e-12,    // resets the absolute current error tolerance of the program
    VNTOL: f64 = 1e-6,      // resets the absolute voltage error tolerance of the program
    TRTOL: f64 = 7.0,       // resets the transient error tolerance
    CHGTOL: f64 = 1e-14,    // resets the charge tolerance of the program
    PIVTOL: f64 = 1e-13,    // resets the absolute minimum value for a matrix entry to be accepted as a pivot
    PIVREL: f64 = 1e-3,     // resets the relative ratio between the largest column entry and an acceptable pivot value
    NUMDGT: u3 = 4,         // resets the number of significant digits printed for output variable values (0 < x < 8)
    TNOM: u64 = 300,        // resets the nominal temperature
    ITL1: u64 = 100,        // resets the dc iteration limit
    ITL2: u64 = 50,         // resets the dc transfer curve iteration limit
    ITL3: u64 = 4,          // resets the lower transient analysis iteration limit
    ITL4: u64 = 10,         // resets the transient analysis timepoint iteration limit
    ITL5: u64 = 5000,       // resets the transient analysis total iteration limit
    CPTIME: u64 = std.math.maxInt(u64), // the maximum cpu-time in seconds allowed for this job
    LIMTIM: u64 = 2,        // resets the amount of cpu time reserved by SPICE for generating plots should a cpu time-limit cause job termination
    LIMPTS: u64 = 201,      // resets the total number of points that can be printed or plotted in a dc, ac, or transient analysis
    LVLCOD: u3 = 2,         // if x is 2 (two), then machine code for the matrix solution will be generated. Otherwise, no machine code is generated
    LVLTIME: u3 = 2,        // if x is 1 (one), the iteration timestep control is used, if x is 2 (two), the truncation-error timestep is used
    METHOD: Method_t = .TRAPEZOIDAL, // sets the numerical integration method used by SPICE. Possible names are Gear or trapezoidal
    MAXORD: u3 = 2,         // sets the maximum order for the integration method if Gear's variable-order method is used
    DEFL: f64 = 100 * u,    // resets the value for MOS channel length
    DEFW: f64 = 100 * u,    // resets the value for MOS channel width
    DEFAD: f64 = 0.0,       // resets the value for MOS drain diffusion area
    DEFAS: f64 = 0.0,       // resets the value for MOS source diffusion area

};

pub const Method_t = union(enum) {
    GEAR,
    TRAPEZOIDAL,
};

test {
    const title_card = Card{ 
        .card_t = Card_t{ 
            .TITLE = TitleCard{
                .title = "First Circuit",
            }
        }
    };
    const r1_card = Card{ .card_t = .ELEMENT };
}