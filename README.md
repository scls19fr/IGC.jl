[![Build Status](https://travis-ci.com/scls19fr/IGC.jl.svg?branch=master)](https://travis-ci.com/scls19fr/IGC.jl)

# IGC

A Julia library to interact with IGC file.

Be aware that this library is alpha version (ie it shouldn't be considered as a release version).

IGC file format is defined using [Technical Specification for IGC-approved GNSS Flight Recorder](http://www.ukiws.demon.co.uk/GFAC/documents/tech_spec_gnss.pdf) from [FAI INTERNATIONAL GLIDING COMMISSION](https://www.fai.org/commission/igc)

## Installation

```julia
julia> using Pkg
julia> Pkg.clone("https://github.com/scls19fr/IGC.jl")
```

## Usage

### Read an IGC file

```julia
julia> using IGC

julia> cd(joinpath(dirname(pathof(IGC)), "..", "test"))

julia> fname = joinpath("data", "example.igc")

julia> igcdoc = read(fname, IGCDocument)

julia> igcdoc.<press_tab>
comment_records       errors                 fix_records            k_records              security_records
dgps_records          event_records          header                 logger_id              stream
eol                   fix_record_extensions  k_record_extensions    satellite_records      task

julia> igcdoc.logger_id
IGC.A_record("XXX", "ABC", "FLIGHT:1")

julia> igcdoc.header
IGC.Header(IGC.H_record_FiXAccuracy('F', 35), IGC.H_record_DaTE('F', 2001-07-16), IGC.H_record_PiLoT('F', "Bloggs Bill D"), IGC.H_record_Copilot('F', "Smith-Barry John A"), IGC.H_record_GliderType('F', "Schleicher ASH-25"), IGC.H_record_GliderRegistration('F', "ABCD-1234"), IGC.H_record_GpsDatum('F', "WGS-1984"), IGC.H_record_FirmwareRevision('F', "6.4"), IGC.H_record_HardwareRevision('F', "3.0"), IGC.H_record_ManufacturerModel('F', "Manufacturer", "Model"), IGC.H_record_GpsReceiver('F', "MarconiCanada", "Superstar", 12, IGC.MaxAlt(10000, "m")), IGC.H_record_PressureAltitudeSensor('F', "Sensyn", "XYZ1111", IGC.MaxAlt(11000, "m")), IGC.H_record_CompetitionId('F', "XYZ-78910"), IGC.H_record_CompetitionClass('F', "15m Motor Glider"))

julia> igcdoc.task.info
IGC.C_record_task_info(IGC.DeclarationInstant(2001-07-15, 21:38:41), 2001-07-16, "0001", 2, "500K Tri")

julia> using DataFrames

julia> DataFrame(igcdoc.task.waypoints)
6×3 DataFrame
│ Row │ latitude             │ longitude               │ description            │
│     │ IGC.IGCLatitude      │ IGC.IGCLongitude        │ String                 │
├─────┼──────────────────────┼─────────────────────────┼────────────────────────┤
│ 1   │ IGCLatitude(51.1893) │ IGCLongitude(-1.03165)  │ Lasham Clubhouse       │
│ 2   │ IGCLatitude(51.1696) │ IGCLongitude(-1.04407)  │ Lasham Start S, Start  │
│ 3   │ IGCLatitude(52.1515) │ IGCLongitude(-2.92045)  │ Sarnesfield, TP1       │
│ 4   │ IGCLatitude(52.5025) │ IGCLongitude(-0.293533) │ Norman Cross, TP2      │
│ 5   │ IGCLatitude(51.1696) │ IGCLongitude(-1.04407)  │ Lasham Start S, Finish │
│ 6   │ IGCLatitude(51.1893) │ IGCLongitude(-1.03165)  │ Lasham Clubhouse       │

julia> DataFrame(igcdoc.fix_records)
9×9 DataFrame. Omitted printing of 3 columns
│ Row │ time     │ latitude             │ longitude              │ validity │ pressure_alt             │ gps_alt             │
│     │ Dates…   │ IGC.IGCLatitude      │ IGC.IGCLongitude       │ IGC…     │ IGC.IGCPressureAltitude  │ IGC.IGCGpsAltitude  │
├─────┼──────────┼──────────────────────┼────────────────────────┼──────────┼──────────────────────────┼─────────────────────┤
│ 1   │ 16:02:40 │ IGCLatitude(54.1187) │ IGCLongitude(-2.82237) │ Fix3D    │ IGCPressureAltitude(280) │ IGCGpsAltitude(421) │
│ 2   │ 16:02:45 │ IGCLatitude(51.1188) │ IGCLongitude(-1.82167) │ Fix3D    │ IGCPressureAltitude(288) │ IGCGpsAltitude(429) │
│ 3   │ 16:02:50 │ IGCLatitude(51.1189) │ IGCLongitude(-1.82138) │ Fix3D    │ IGCPressureAltitude(290) │ IGCGpsAltitude(432) │
│ 4   │ 16:02:55 │ IGCLatitude(51.119)  │ IGCLongitude(-1.82035) │ Fix3D    │ IGCPressureAltitude(290) │ IGCGpsAltitude(430) │
│ 5   │ 16:03:00 │ IGCLatitude(51.1192) │ IGCLongitude(-1.82003) │ Fix3D    │ IGCPressureAltitude(291) │ IGCGpsAltitude(432) │
│ 6   │ 16:03:05 │ IGCLatitude(51.1197) │ IGCLongitude(-1.81975) │ Fix3D    │ IGCPressureAltitude(291) │ IGCGpsAltitude(435) │
│ 7   │ 16:03:10 │ IGCLatitude(51.1202) │ IGCLongitude(-1.81957) │ Fix3D    │ IGCPressureAltitude(293) │ IGCGpsAltitude(435) │
│ 8   │ 16:02:48 │ IGCLatitude(51.1203) │ IGCLongitude(-1.81917) │ Fix3D    │ IGCPressureAltitude(494) │ IGCGpsAltitude(436) │
│ 9   │ 16:02:52 │ IGCLatitude(51.1222) │ IGCLongitude(-1.81878) │ Fix3D    │ IGCPressureAltitude(496) │ IGCGpsAltitude(439) │

```

### Parse a string containing a given IGC record

```julia
julia> using IGC

julia> parse(Abstract_IGC_record, "B1602455107126N00149300WA002880042919509020")
IGC.B_record(Time(16:02:45), IGC.IGCLatitude(51.118766666666666), IGC.IGCLongitude(-1.8216666666666668), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(288), IGC.IGCGpsAltitude(429), 36, "19509020", IGC.IGCExtension[])
```

### Parse a string containing several IGC records

```julia
julia> using IGC

julia> records = parse(Vector{Abstract_IGC_record}, """B1602455107126N00149300WA002880042919509020
       B1602505107134N00149283WA002900043221009015
       B1602555107140N00149221WA002900043020009012""")
3-element Array{IGC.B_record,1}:
 IGC.B_record(16:02:45, IGC.IGCLatitude(51.118766666666666), IGC.IGCLongitude(-1.8216666666666668), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(288), IGC.IGCGpsAltitude(429), 36, "19509020", IGC.IGCExtension[])
 IGC.B_record(16:02:50, IGC.IGCLatitude(51.1189), IGC.IGCLongitude(-1.8213833333333334), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(432), 36, "21009015", IGC.IGCExtension[])
 IGC.B_record(16:02:55, IGC.IGCLatitude(51.119), IGC.IGCLongitude(-1.82035), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(430), 36, "20009012", IGC.IGCExtension[])

julia> using DataFrames

julia> DataFrame(records)
3×9 DataFrame. Omitted printing of 3 columns
│ Row │ time     │ latitude             │ longitude              │ validity │ pressure_alt             │ gps_alt             │
│     │ Dates…   │ IGC.IGCLatitude      │ IGC.IGCLongitude       │ IGC…     │ IGC.IGCPressureAltitude  │ IGC.IGCGpsAltitude  │
├─────┼──────────┼──────────────────────┼────────────────────────┼──────────┼──────────────────────────┼─────────────────────┤
│ 1   │ 16:02:45 │ IGCLatitude(51.1188) │ IGCLongitude(-1.82167) │ Fix3D    │ IGCPressureAltitude(288) │ IGCGpsAltitude(429) │
│ 2   │ 16:02:50 │ IGCLatitude(51.1189) │ IGCLongitude(-1.82138) │ Fix3D    │ IGCPressureAltitude(290) │ IGCGpsAltitude(432) │
│ 3   │ 16:02:55 │ IGCLatitude(51.119)  │ IGCLongitude(-1.82035) │ Fix3D    │ IGCPressureAltitude(290) │ IGCGpsAltitude(430) │
```

### Read an IGC file to a simple Vector of records

```julia
julia> records = parse(Vector{Abstract_IGC_record}, read(fname, String))
46-element Array{Abstract_IGC_record,1}:
 IGC.A_record("XXX", "ABC", "FLIGHT:1")
 IGC.H_record_FiXAccuracy('F', 35)
 IGC.H_record_DaTE('F', 2001-07-16)
 ⋮
 IGC.G_record("SKTO5427FGTNUT5621WKTC6714FT8957FGMKJ134527FGTR6751")
 IGC.G_record("K2489IERGNV3089IVJE39GO398535J3894N358954983FTGY546")
 IGC.G_record("12560DJUWT28719GTAOL5628FGWNIST78154INWTOLP7815FITN")
```

### Write an IGC record to a string

```julia
julia> using Dates

julia> using IGC: B_record, IGCLatitude, IGCLongitude, FixValidity, IGCPressureAltitude, IGCGpsAltitude

julia> rec = B_record(Time(16, 02, 45), IGCLatitude(51.118766666666666), IGCLongitude(-1.8216666666666668), FixValidity.Fix3D, IGCPressureAltitude(288), IGCGpsAltitude(429), 36, "19509020")

julia> rec = B_record(Time(16, 02, 45), IGCLatitude(51.118766666666666), IGCLongitude(-1.8216666666666668), FixValidity.Fix3D, IGCPressureAltitude(288), IGCGpsAltitude(429), 36, "19509020")
B_record(Time(16:02:45), IGCLatitude(51.118766666666666), IGCLongitude(-1.8216666666666668), IGC.FixValidity.Fix3D, IGCPressureAltitude(288), IGCGpsAltitude(429), 36, "19509020", IGC.IGCExtension[])

julia> string(rec)
"B1602455107126N00149300WA002880042919509020"
```

### Write an IGC file using a stream approach

```julia
julia> using IGC

julia> using IGC: ParsingMode, A_record, H_record_FiXAccuracy, H_record_DaTE, H_record_PiLoT, update!

julia> io = IOBuffer()  # this buffer is filled at each update! call
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=true, append=false, size=0, maxsize=Inf, ptr=1, mark=-1)

julia> igcdoc = IGCDocument(stream = io, parsing_mode = ParsingMode.STRICT)

julia> update!(igcdoc, A_record("XXX", "ABC", "FLIGHT:1"))
16

julia> update!(igcdoc, H_record_FiXAccuracy('F', 35))
3

julia> update!(igcdoc, H_record_DaTE('F', Date(2001, 07, 16)))
6

julia> update!(igcdoc, H_record_PiLoT('F', "Bloggs Bill D"))
13

julia> String(take!(io))
"AXXXABC FLIGHT:1\nHFFXA035\nHFDTE160701\nHFPLTPILOTINCHARGE:Bloggs Bill D"
```

## Credits

Inspired by Python library [aerofiles](https://github.com/Turbo87/aerofiles/)
