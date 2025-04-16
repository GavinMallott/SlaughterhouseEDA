const std = @import("std");
const printf = std.debug.print;
fn prints(s: []const u8) void {
    printf("{s}\n", .{s});
}

pub const DEBUG = true;

const file = @embedFile("sample.net");

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

pub const Card_t = enum(u8){
    TITLE,
    COMMENT,
    END,
    SUBCKT_DEF,              //.SUBCKT subnam N1 <N2,N3,N4 ...>   ###   .SUBCKT OPAMP 1 2 3 4
    
    MODEL,                   //.MODEL MNAME TYPE(PNAME1=PVAL1 PNAME2=PVAL2 ... )   ###   .MODEL MOD1 NPN BF=50 IS=1E-13 VBF=50
    
    // ELEMENTS:
    R,   //RESISTOR            RXXXXXXX N1 N2 VALUE <TC=TC1<,TC2>>   ###   RC1 12 17 1K TC=0.001,0.015
    C,   //CAPACITOR           CXXXXXXX N+ N- VALUE <IC=INCOND>   ###   COSC 17 23 10U IC=3V
    L,   //INDUCTOR            LXXXXXXX N+ N- VALUE <IC=INCOND>   ###   LSHUNT 23 51 10U IC=15.7MA
    K,   //COUPLED_INDUCTOR    KXXXXXXX LYYYYYYY LZZZZZZZ VALUE   ###   KXFRMR L1 L2 0.87
    T,   //TRANSMISSION_LINE   TXXXXXXX N1 N2 N3 N4 Z0=VALUE <TD=VALUE> <F=FREQ <NL=NRMLEN>>+<IC=V1,I1,V2,I2>   ###   T1 1 0 2 0 Z0=50 TD=10NS

    //Independant Sources (IS)
    V,   //VOLTAGE             VXXXXXXX N+ N- <<DC> DC/TRAN VALUE> <AC <ACMAG <ACPHASE>>>   ###   VIN 13 2 0.001 AC 1 SIN(0 1 1MEG)
    I,   //CURRENT             IYYYYYYY N+ N- <<DC> DC/TRAN VALUE> <AC <ACMAG <ACPHASE>>>   ###   ISRC 23 21 AC 0.333 45.0 SFFM(0 1 10K 5 1K)

    //Dependant Sources (DS)
    G,   //VCCS                GXXXXXXX N+ N- NC+ NC- VALUE   ###   G1 2 0 5 0 0.1MMHO
    E,   //VCVS                EXXXXXXX N+ N- NC+ NC- VALUE   ###   E1 2 3 14 1 2.0
    F,   //CCCS                FXXXXXXX N+ N- VNAM VALUE   ###   F1 13 5 VSENS 5
    H,   //CCVS                HXXXXXXX N+ N- VNAM VALUE   ###   HX 5 17 VZ 0.5K

    //Semiconductor Devices (SD) Requires .MODEL Card in Deck
    D,   //DIODE               DXXXXXXX N+ N- MNAME <AREA> <OFF> <IC=VD>   ###   DCLMP 3 7 DMOD 3.0 IC=0.2
    Q,   //BJT                 QXXXXXXX NC NB NE <NS> MNAME <AREA> <OFF> <IC=VBE,VCE>   ###   Q23 10 24 13 QMOD IC=0.6,5.0
    J,   //JFET                JXXXXXXX ND NG NS MNAME <AREA> <OFF> <IC=VDS,VGS>   ###   J1 7 2 3 JM1 OFF
    M,   //MOSFET              MXXXXXXX ND NG NS NB MNAME <L=VAL> <W=VAL> <AD=VAL> <AS=VAL> <PD=VAL> <PS=VAL> <NRD=VAL> <NRS=VAL> <OFF> <IC=VDS,VGS,VBS>

    //Subcircuit Call (SC) Requires .SUBCKT Definition in Deck
    X,   //SUBCKT_CALL         XXXXXXXX N1 <N2,N3,N4...> SUBNAM   ###   X1 2 4 17 3 1 MULTI

    // CONTROLS:
    TEMP,                      //.TEMP T1 <T2,T3,T4 ...>   ###   .TEMP -55.0 25.0 125.0
    WIDTH,                     //.WIDTH IN=COLNUM OUT=COLNUM   ###   .WIDTH IN=72 OUT=133
    OPTIONS,                   //.OPTIONS OPT1 OPT2 ... (or OPT=OPTVAL ...)   ###   .OPTIONS ACCT LIST NODE
    OP,                        //.OP   ###   Force Determine DC Operating Point (Inductors shorted, Capacitors opened) Will be called automattically if no other analysis is called
    DC,                        //.DC SRCNAM VSTART VSTOP VINCR [SRC2 START2 STOP2 INCR2]   ###   .DC VCE 0 10 .25 IB 0 10U 1U   (DC Sweep requires at least one IS with DC Value)
    NODESET,                   //.NODESET V(NODNUM)=VAL V(NODNUM)=VAL ...   ###   .NODESET V(12)=4.5 V(4)=2.23   (Sets Voltage or Current at specified node)
    IC,                        //.IC V(NODNUM)=VAL V(NODNUM)=VAL ...   ###   .IC V(11)=5 V(4)=-5 V(2)=2.2   (Transient Initial Conditions)
    TF,                        //.TF OUTVAR INSRC   ###   .TF V(5,3) VIN   (DC Small-Signal Transfer Function)
    SENS,                      //.SENS OV1 <OV2 ... >   ###   .SENS V(9) V(4,3) V(17) I(VCC)   (DC Small=Signal Sensitivity)
    AC,                        //.AC DEC ND FSTART FSTOP or .AC OCT NO FSTART FSTOP or .AC LIN NP FSTART FSTOP   (AC Analysis requires at least on IS with AC Value)
    DISTO,                     //.DISTO RLOAD <INTER <SKW2 <REFPWR <SPW2>>>>   ###   .DISTO RL 2 0.95 1.0E-3 0.75   (Compute Distortion)
    NOISE,                     //.NOISE OUTV INSRC NUMS   ###   .NOISE V(5) VIN 10   (Noise Analysis used with AC Card)
    TRAN,                      //.TRAN TSTEP TSTOP <TSTART <TMAX>> <UIC>   ###   .TRAN 1NS 1000NS 500NS   (Perform Transient Analysis)
    FOUR,                      //.FOUR FREQ OV1 <OV2 OV3 ...>   ###   .FOUR 100K  V(5)   (Perform Fourier Analysis w/ fundamental frequency and specified output variables)
    PRINT,                     //.PRINT PRTYPE OV1 <OV2 ... OV8>   ###   .PRINT DC V(2) I(VSRC) V(23,17)
    PLOT,                      //.PLOT PLTYPE OV1 <(PLO1,PHI1)> <OV2 <(PLO2,PHI2)> ... OV8>   ###   .PLOT AC VM(5) VM(31,24) VDB(5) VP(5)


};

pub const Signal_t = enum(u8){
    PULSE,                  //PULSE(V1 V2 TD TR TF PW PER)   ###   VIN 3 0 PULSE(-1 1 2NS 2NS 2NS 50NS 100NS)
    SIN,                    //SIN(VO VA FREQ TD THETA)   ###   VIN 3 0 SIN(0 1 100MEG 1NS 1E10)
    EXP,                    //EXP(V1 V2 TD1 TAU1 TD2 TAU2)   ###   VIN 3 0 EXP(-4 -1 2NS 30NS 60NS 40NS)
    PWL,                    //PWL(T1 V1 )   ###   VCLOCK 7 5 PWL(0 -7 10NS -7 11NS -3 17NS -3 18NS -7 50NS -7)
    SFFM,                   //SFFM(VO VA FC MDI FS)   ###   V1 12 0 SFFM(0 1M 20K 5 1K)

};

pub const Model_t = enum(u8){    
    D,
    NPN,
    PNP,
    NJF,
    PJF,
    NMOS,
    PMOS,

};

pub const Options = struct {
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

pub const Method_t = enum(u8) {
    GEAR,
    TRAPEZOIDAL,
};

pub const Component = struct {
    comp_t: Component_t,
    uuid: []const u8,
    designator: []const u8,
    nodes: [][]const u8,
    value: ?f64,
    model: ?Model,
    args: std.StringHashMap([]const u8),

    pub const Component_t = enum(u8) {
        RESISTOR,
        CAPACITOR,
        INDUCTOR,
        COUPLED_INDUCTOR,
        TRANSMISSION_LINE,

        VOLTAGE_SOURCE,
        CURRENT_SOURCE,

        VCVS,
        CCVS,
        VCCS,
        CCCS,

        DIODE,
        BJT,
        JFET,
        MOSFET,

        SUBCKT,

    };

    pub fn deinit(self: *@This()) void {
        self.args.deinit();

    }

};

pub const Control = struct {

};

pub const Model = struct {

};

pub const SpiceError = error{
    InvalidComponentArgument,
    OutOfMemory,
    InvalidValue,
};

pub const Spice = struct {
    title: []const u8,
    comments: std.ArrayList([]const u8),
    opts: Options,

    components: std.ArrayList(Component),
    models: std.ArrayList(Model),
    controls: std.ArrayList(Control),

    ally: std.mem.Allocator,


    pub const Self = @This();

    pub fn init(ally: std.mem.Allocator) !Self {
        return .{
            .title = "",
            .components = std.ArrayList(Component).init(ally),
            .models = std.ArrayList(Model).init(ally),
            .controls = std.ArrayList(Control).init(ally),
            .comments = std.ArrayList([]const u8).init(ally),
            .opts = Options{},
            .ally = ally,
        };
    }

    pub fn deinit(self: *Self) void {
        self.comments.deinit();
        for (self.components.items) |*comp| {
            comp.deinit();
        }
        self.components.deinit();
        self.controls.deinit();
    }

    pub fn genId(self: *Self) []const u8 {
        _ = self;
        return "";
    }

    pub fn parseComponent(self: *Self, ct: Component.Component_t, instr: []const u8) SpiceError!Component {
        var words = std.mem.splitSequence(u8, instr, " ");
        var new_component: Component = undefined;
        switch (ct) {
            .RESISTOR => {
                
                const designator = words.next();
                const net1 = words.next();
                const net2 = words.next();
                const value = words.next();
                if (designator == null) return SpiceError.InvalidComponentArgument;
                if (net1 == null) return SpiceError.InvalidComponentArgument;
                if (net2 == null) return SpiceError.InvalidComponentArgument;
                if (value == null) return SpiceError.InvalidComponentArgument;

                const fvalue = self.parseFloat(f64, value.?) catch unreachable;

                const nodes = [_][]const u8 {net1.?, net2.?};
                var args = std.StringHashMap([]const u8).init(self.ally);
                while(words.next()) |arg| {
                    args.put("TC", arg) catch |e| {
                        return e;
                    };
                }

                new_component = Component{
                    .comp_t = ct,
                    .uuid = self.genId(),
                    .designator = designator.?,
                    .model = null,
                    .nodes = @constCast(nodes[0..]),
                    .value = fvalue,
                    .args = args,

                };
            },
            .CAPACITOR => {},
            else => {},
        }
        return new_component;
    }

    fn parseFloat(self: *Self, comptime ctx: type, s: []const u8) !ctx {
        _ = self;
        const len = s.len - 1;
        const num = s[0..len];
        const mod = s[len..];

        var val = try std.fmt.parseFloat(ctx, num);

        if(std.mem.eql(u8, "k", mod)) {
            val *= k;
        }
        if(std.mem.eql(u8, "M", mod)) {
            val *= M;
        }
        if(std.mem.eql(u8, "G", mod)) {
            val *= G;
        }
        if(std.mem.eql(u8, "T", mod)) {
            val *= T;
        }
        if(std.mem.eql(u8, "P", mod)) {
            val *= P;
        }
        if(std.mem.eql(u8, "m", mod)) {
            val *= m;
        }
        if(std.mem.eql(u8, "u", mod)) {
            val *= u;
        }
        if(std.mem.eql(u8, "n", mod)) {
            val *= n;
        }
        if(std.mem.eql(u8, "p", mod)) {
            val *= p;
        }
        if(std.mem.eql(u8, "f", mod)) {
            val *= f;
        }

        return val;

    }

    pub fn addComponent(self: *Self, c: Component) void {
        self.components.append(c) catch unreachable;
    }


    pub fn createModel(self: *Self, model_t: Model_t, args: []const u8) void {
        _ = self;
        _ = args;
        _ = model_t;
    }

    pub fn addOptions(self: *Self, opt_line: []const u8) void {
        var words = std.mem.splitSequence(u8, opt_line, " ");
        while(words.next()) |word| {    
            var val_opt = std.mem.splitSequence(u8, word, "=");
            const kword = val_opt.next().?;
            const value = val_opt.next();

            if (std.mem.eql(u8, kword, "LIST") == true) {
                self.opts.LIST = true;
                if (DEBUG) printf("Set option {s} to true.\n", .{kword});
            } else if (std.mem.eql(u8, kword, "NODE") == true) {
                self.opts.NODE = true;
                if (DEBUG) printf("Set option {s} to true.\n", .{kword});
            } else if (std.mem.eql(u8, kword, "LIMPTS") == true) {
                const int_val: u64 = std.fmt.parseInt(u64, value.?, 10) catch unreachable;
                self.opts.LIMPTS = int_val;
                if (DEBUG) printf("Set option {s} to {d}.\n", .{kword, int_val});
            }

        }
    }

    pub fn dispOptions(self: *Self) void {
        prints("");
        prints("        -- OPTIONS --");
        printf("ACCT: {}\n", .{self.opts.ACCT});
        printf("LIST: {}\n", .{self.opts.LIST}); 
        printf("NOMOD: {}\n", .{self.opts.NOMOD});
        printf("NOPAGE: {}\n", .{self.opts.NOPAGE});
        printf("NODE: {}\n", .{self.opts.NODE});
        printf("OPTS: {}\n", .{self.opts.OPTS}); 
        printf("GMIN: {d}\n", .{self.opts.GMIN}); 
        printf("RELTOL: {d}\n", .{self.opts.RELTOL});
        printf("ABSTOL: {d}\n", .{self.opts.ABSTOL});
        printf("VNTOL: {d}\n", .{self.opts.VNTOL});
        printf("TRTOL: {d}\n", .{self.opts.TRTOL});
        printf("CHGTOL: {d}\n", .{self.opts.CHGTOL});
        printf("PIVTOL: {d}\n", .{self.opts.PIVTOL});
        printf("PIVREL: {d}\n", .{self.opts.PIVREL});
        printf("NUMDGT: {d}\n", .{self.opts.NUMDGT});
        printf("TNOM: {d}\n", .{self.opts.TNOM});
        printf("ITL1: {d}\n", .{self.opts.ITL1});
        printf("ITL2: {d}\n", .{self.opts.ITL2});
        printf("ITL3: {d}\n", .{self.opts.ITL3});
        printf("ITL4: {d}\n", .{self.opts.ITL4});
        printf("ITL5: {d}\n", .{self.opts.ITL5});
        printf("CPTIME: {d}\n", .{self.opts.CPTIME});
        printf("LIMTIM: {d}\n", .{self.opts.LIMTIM});
        printf("LIMPTS: {d}\n", .{self.opts.LIMPTS});
        printf("LVLCOD: {d}\n", .{self.opts.LVLCOD});
        printf("LVLTIME: {d}\n", .{self.opts.LVLTIME});
        const method_str = switch (self.opts.METHOD){
            .TRAPEZOIDAL => "Trapezoidal",
            .GEAR => "Gear",
        };
        printf("METHOD: {s}\n", .{method_str});
        printf("MAXORD: {d}\n", .{self.opts.MAXORD});
        printf("DEFL: {d}\n", .{self.opts.DEFL});
        printf("DEFW: {d}\n", .{self.opts.DEFW}); 
        printf("DEFAD: {d}\n", .{self.opts.DEFAD});
        printf("DEFAS: {d}\n", .{self.opts.DEFAS});
    }
};

pub fn getField(comptime ctx: type, instance: ctx, field_name: []const u8) ?anyopaque {
    const fields = std.meta.fields(ctx);
    inline for (fields) |field| {
        if (std.mem.eql(u8, field.name, field_name)) {
            return @field(instance, field.name);
        }
    }
    return null;
}


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var SpiceEngine = try Spice.init(ally);
    defer SpiceEngine.deinit();

    var lines = std.mem.splitSequence(u8, file, "\r\n");
    while(lines.next()) |line| {
        // Check for empty line
        const trimmed = std.mem.trim(u8, line, "\t\r\n");
        if (trimmed.len == 0) continue;
        
        // Check for . Command
        if (std.mem.eql(u8, ".", line[0..1]) == true) {
            var words = std.mem.splitSequence(u8, line[1..], " ");
            const cmd_str = words.next().?;
            const cmd: Card_t = std.meta.stringToEnum(Card_t, cmd_str).?;
            switch (cmd) {
                .END => {
                    prints("EOF");
                    prints("");
                },
                .MODEL => {
                    prints(line);
                    //Spice.createModel(.D, line);
                },
                .OPTIONS => {
                    SpiceEngine.addOptions(line[9..]);
                    //SpiceEngine.dispOptions();
                },
                .DC => {

                },
                else => {
                    prints("Not valid . command");
                }
            }

        } else if (std.mem.eql(u8, "*", line[0..1]) == true) {
            try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "R", line[0..1]) == true) {
            const new_r = try SpiceEngine.parseComponent(.RESISTOR, line);
            SpiceEngine.addComponent(new_r);

        } else if (std.mem.eql(u8, "C", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "L", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "K", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "T", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "V", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "I", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "G", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "E", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "F", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "H", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "D", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "Q", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "J", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "M", line[0..1]) == true) {
            //try SpiceEngine.comments.append(line[1..]);

        } else if (std.mem.eql(u8, "X", line[0..1]) == true) {
           // try SpiceEngine.comments.append(line[1..]);

        } else {
            SpiceEngine.title = line;
            printf("Netlist Title: {s}\n", .{SpiceEngine.title});
        }

    }

    prints("Netlist Comments:");
    for (SpiceEngine.comments.items) |c| {
        
        prints(c);
    }
}