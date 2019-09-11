[![Build Status](https://travis-ci.com/scls19fr/IGC.jl.svg?branch=master)](https://travis-ci.com/scls19fr/IGC.jl)

# IGC

A Julia library to interact with IGC file.

Be aware that this library is alpha version (ie it shouldn't be considered as a release version).

IGC file format is defined using [Technical Specification for IGC-approved GNSS Flight Recorder](http://www.ukiws.demon.co.uk/GFAC/documents/tech_spec_gnss.pdf) from [FAI INTERNATIONAL GLIDING COMMISSION](https://www.fai.org/commission/igc)

## Usage

### Read IGC file

```julia
julia> using IGC
julia> cd(joinpath(dirname(pathof(IGC)), "..", "test"))
julia> fname = joinpath("data", "example.igc")
julia> igcdoc = read(fname, IGCDocument)
julia> igcdoc.<press_tab>
comment_records       errors                 fix_records            k_records              security_records
dgps_records          event_records          header                 logger_id              stream
eol                   fix_record_extensions  k_record_extensions    satellite_records      task
julia> igcdoc.
julia> igcdoc.fix_records
9-element Array{IGC.B_record,1}:
 IGC.B_record(Time(16:02:40), IGC.IGCLatitude(54.11868333333334), IGC.IGCLongitude(-2.8223666666666665), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(280), IGC.IGCGpsAltitude(421), 36, "20509950", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:45), IGC.IGCLatitude(51.118766666666666), IGC.IGCLongitude(-1.8216666666666668), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(288), IGC.IGCGpsAltitude(429), 36, "19509020", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:50), IGC.IGCLatitude(51.1189), IGC.IGCLongitude(-1.8213833333333334), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(432), 36, "21009015", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:55), IGC.IGCLatitude(51.119), IGC.IGCLongitude(-1.82035), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(430), 36, "20009012", IGC.IGCExtension[])
 IGC.B_record(Time(16:03:00), IGC.IGCLatitude(51.119166666666665), IGC.IGCLongitude(-1.8200333333333334), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(291), IGC.IGCGpsAltitude(432), 36, "25608009", IGC.IGCExtension[])
 IGC.B_record(Time(16:03:05), IGC.IGCLatitude(51.11966666666667), IGC.IGCLongitude(-1.81975), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(291), IGC.IGCGpsAltitude(435), 36, "21008015", IGC.IGCExtension[])
 IGC.B_record(Time(16:03:10), IGC.IGCLatitude(51.1202), IGC.IGCLongitude(-1.8195666666666668), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(293), IGC.IGCGpsAltitude(435), 36, "19608024", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:48), IGC.IGCLatitude(51.120333333333335), IGC.IGCLongitude(-1.8191666666666666), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(494), IGC.IGCGpsAltitude(436), 36, "19008018", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:52), IGC.IGCLatitude(51.122166666666665), IGC.IGCLongitude(-1.8187833333333334), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(496), IGC.IGCGpsAltitude(439), 36, "19508015", IGC.IGCExtension[])
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
julia> parse(Vector{Abstract_IGC_record}, """B1602455107126N00149300WA002880042919509020
B1602505107134N00149283WA002900043221009015
B1602555107140N00149221WA002900043020009012""")
3-element Array{IGC.B_record,1}:
 IGC.B_record(Time(16:02:45), IGC.IGCLatitude(51.118766666666666), IGC.IGCLongitude(-1.8216666666666668), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(288), IGC.IGCGpsAltitude(429), 36, "19509020", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:50), IGC.IGCLatitude(51.1189), IGC.IGCLongitude(-1.8213833333333334), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(432), 36, "21009015", IGC.IGCExtension[])
 IGC.B_record(Time(16:02:55), IGC.IGCLatitude(51.119), IGC.IGCLongitude(-1.82035), IGC.FixValidity.Fix3D, IGC.IGCPressureAltitude(290), IGC.IGCGpsAltitude(430), 36, "20009012", IGC.IGCExtension[])
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
