function parse(::Type{Time}, s::String, ::Type{IGCTimeFormat})
    return Time(s, IGC_TIME_FMT)
end

function parse(::Type{Date}, s::String, ::Type{IGCDateFormat})
    m = match(DATE_PATTERN, s)
    day = parse(Int, m[1])
    month = parse(Int, m[2])
    year = parse(Int, m[3])
    year = 2000 + year
    return Date(year, month, day)
end

function parse(::Type{IGCLatitude}, s::String)
    d = parse(Int64, s[1:2])
    m = parse(Float64, s[3:7]) / 1000.
    ordinal = s[8]

    latitude = d + m / 60.

    if !(0. <= latitude <= 90.)
        throw(ArgumentError("Invalid latitude format $(repr(s)) - range error"))
    end

    if ordinal ∉ ('S', 'N')
        throw(ArgumentError("Invalid latitude format $(repr(s)) - ordinal error"))
    end

    if ordinal == 'S'
        latitude = -latitude
    end

    return IGCLatitude(latitude)
end

function parse(::Type{IGCLongitude}, s::String)
    d = parse(Float64, s[1:3])
    m = parse(Float64, s[4:8]) / 1000.
    ordinal = s[9]

    longitude = d + m / 60.

    if !(0. <= longitude <= 180.)
        throw(ArgumentError("Invalid longitude format $(repr(s)) - range error"))
    end

    if ordinal ∉ ('W', 'E')
        throw(ArgumentError("Invalid longitude format $(repr(s)) - ordinal error"))
    end

    if ordinal == 'W'
        longitude = -longitude
    end

    return IGCLongitude(longitude)
end

function parse(::Type{IGCPressureAltitude}, s::String)
    return IGCPressureAltitude(parse(Int, s))
end

function parse(::Type{IGCGpsAltitude}, s::String)
    return IGCGpsAltitude(parse(Int, s))
end

# ========================================

function parse(::Type{A_record}, line::String)
    @assert line[1] == 'A'
    id_addition = length(line) == 7 ? "" : strip(line[8:end])
    return A_record(line[2:4], line[5:7], id_addition)
end

function parse(::Type{B_record}, line::String)
    @assert line[1] == 'B'

    return B_record(
        parse(Time, line[2:7], IGCTimeFormat),
        parse(IGCLatitude, line[8:15]),
        parse(IGCLongitude, line[16:24]),
        FixValidity.parse(line[25]),
        parse(IGCPressureAltitude, line[26:30]),
        parse(IGCGpsAltitude, line[31:35]),
        36,
        strip(line[36:end])
    )
end

function parse(::Type{Abstract_C_record}, line::String)
    @assert line[1] == 'C'

    istaskinfo = isdigit(line[9])

    if istaskinfo
        return C_record_task_info(
            parse(Date, line[2:7], IGCDateFormat),
            parse(Time, line[8:13], IGCTimeFormat),
            parse(Date, line[14:19], IGCDateFormat),
            line[20:23],
            parse(Int64, line[24:25]),
            strip(line[26:end])
        )
    else
        return C_record_waypoint_info(
            parse(IGCLatitude, line[2:9]),
            parse(IGCLongitude, line[10:18]),
            strip(line[19:end])
        )
    end
end

function parse(::Type{D_record}, line::String)
    @assert line[1] == 'D'
    qualifier = GpsQualifier.parse(line[2])
    station_id = line[3:6]
    return D_record(
        qualifier,
        station_id
    )
end

function parse(::Type{E_record}, line::String)
    @assert line[1] == 'E'
    time = parse(Time, line[2:7], IGCTimeFormat)
    tlc = line[8:10]
    extension_string = strip(line[11:end])
    return E_record(
        time,
        tlc,
        extension_string
    )
end

function parse(::Type{F_record}, line::String)
    @assert line[1] == 'F'

    time = parse(Time, line[2:7], IGCTimeFormat)

    # each satellite ID should have two digits
    if (length(strip(line)) - 7) % 2 != 0
        throw(ArgumentError("F record formatting is incorrect"))
    end

    satellites = []
    nb_satellites = floor(Int, (length(strip(line)) - 7) / 2)

    starting_byte = 8
    for satelite_index in 1:nb_satellites
        push!(satellites, line[starting_byte:starting_byte + 1])
        starting_byte += 2
    end

    return F_record(
        time,  # time
        satellites  # satellites
    )
end


function parse(::Type{G_record}, line::String)
    @assert line[1] == 'G'

    security_code = strip(line[2:end])

    return G_record(
        security_code
    )
end

function parse(::Type{IGCExtension}, line::String)
    nb_extensions = parse(Int64, line[2:3])

    if nb_extensions * 7 + 3 != length(strip(line))
        throw(ArgumentError("I record contains incorrect number of digits"))
    end

    extensions = IGCExtension[]

    for extension_index in 0:nb_extensions - 1
        extension_str = line[extension_index * 7 + 4:(extension_index + 1) * 7 + 3]
        start_byte = parse(Int64, extension_str[1:2])
        end_byte = parse(Int64, extension_str[3:4])
        tlc = extension_str[5:7]

        extension = IGCExtension(start_byte:end_byte, tlc)
        push!(extensions, extension)
    end

    return extensions
end

function parse(::Type{I_record}, line::String)
    @assert line[1] == 'I'

    line = string(strip(line))

    extensions = parse(IGCExtension, line)

    return I_record(extensions)
end

function parse(::Type{J_record}, line::String)
    @assert line[1] == 'J'

    line = string(strip(line))

    extensions = parse(IGCExtension, line)

    return J_record(extensions)
end

# ========================================

function parse(::Type{H_record_FiXAccuracy}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.FXA(.*)"i
    m = match(pattern, line)
    fix_accuracy = m[1]
    if length(fix_accuracy) == 0
        fix_accuracy = missing
        return H_record_FiXAccuracy(source, fix_accuracy)
    else
        fix_accuracy = parse(Int, fix_accuracy)
        return H_record_FiXAccuracy(source, fix_accuracy)
    end    
end

function parse(::Type{H_record_DaTE}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.DTE(\d\d\d\d\d\d)"i
    m = match(pattern, line)
    date_str = string(m[1])
    date = parse(Date, date_str, IGCDateFormat)
    return H_record_DaTE(source, date)
end

function parse(::Type{H_record_PiLoT}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.PLT.*: ?(.*)"i
    m = match(pattern, line)
    name = m[1]
    return H_record_PiLoT(source, name)
end

function parse(::Type{H_record_Copilot}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.CM2CREW2: ?(.*)"i
    m = match(pattern, line)
    name = m[1]
    return H_record_Copilot(source, name)
end

function parse(::Type{H_record_GliderType}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.GTYGLIDERTYPE: ?(.*)"i
    m = match(pattern, line)
    return H_record_GliderType(source, m[1])
end

function parse(::Type{H_record_GliderRegistration}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.GIDGLIDERID: ?(.*)"i
    m = match(pattern, line)
    return H_record_GliderRegistration(source, m[1])
end

function parse(::Type{H_record_GpsDatum}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.DTM100GPSDATUM: ?(.*)"i
    m = match(pattern, line)
    return H_record_GpsDatum(source, m[1])
end

function parse(::Type{H_record_FirmwareRevision}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.RFWFIRMWAREVERSION: ?(.*)"i
    m = match(pattern, line)
    return H_record_FirmwareRevision(source, m[1])
end

function parse(::Type{H_record_HardwareRevision}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.RHWHARDWAREVERSION: ?(.*)"i
    m = match(pattern, line)
    return H_record_HardwareRevision(source, m[1])
end

function parse(::Type{H_record_ManufacturerModel}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.FTYFRTYPE: ?(.*),(.*)"i
    m = match(pattern, line)
    manufacturer = string(strip(m[1]))
    model = strip(m[2])
    return H_record_ManufacturerModel(source, manufacturer, model)
end

function parse(::Type{H_record_GpsReceiver}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.GPS: ?(.*)"i
    m = match(pattern, line)
    s_gps_receiver = m[1]
    t = split(s_gps_receiver, ",")

    if length(t) == 1
        manufacturer = t[1]
        model = ""
        channels = ""
        max_alt = ""
    elseif length(t) == 2
        manufacturer, model = t
        channels = ""
        max_alt = ""
    elseif length(t) == 3
        manufacturer, channels, max_alt = t
        model = ""
    elseif length(t) == 4
        manufacturer, model, channels, max_alt = t
    else
        throw(ArgumentError("Invalid GpsReceiver $line"))
    end

    manufacturer = strip(manufacturer)
    model = strip(model)
    channels = strip(channels)
    max_alt = strip(max_alt)

    if length(channels) > 0
        pattern = r"(\d*)(ch)?"i
        m = match(pattern, channels)
        channels = parse(Int, m[1])
    else
        channels = missing
    end

    if length(max_alt) > 0
        pattern = r"(max)?(\d*)(\D*)"i
        m = match(pattern, max_alt)
        max_alt_value = parse(Int, strip(m[2]))

        max_alt_unit = m[3]
        if !ismissing(max_alt_value) && length(max_alt_unit) == 0
            max_alt_unit = "m"
        end    
    else
        max_alt_value = missing
        max_alt_unit = ""
    end

    max_alt = MaxAlt(max_alt_value, max_alt_unit)

    return H_record_GpsReceiver(source,
        manufacturer,
        model,
        channels,
        max_alt
    )
end

function parse(::Type{H_record_PressureAltitudeSensor}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.PRSPRESSALTSENSOR: ?(.*)"i
    m = match(pattern, line)
    s = m[1]
    t = split(s, ",")

    if length(t) == 1
        manufacturer = t[1]
        model = ""
        max_alt = ""
    elseif length(t) == 2
        manufacturer, model = t
        max_alt = ""
    elseif length(t) == 3
        manufacturer, model, max_alt = t
    else
        throw(ArgumentError("Invalid PressureAltitudeSensor $line"))
    end

    manufacturer = string(strip(manufacturer))
    model = string(strip(model))
    max_alt = strip(max_alt)

    if length(max_alt) > 0
        pattern = r"(max)?(\d*)(\D*)"i
        m = match(pattern, max_alt)
        max_alt_value = parse(Int, strip(m[2]))

        max_alt_unit = m[3]
        if !ismissing(max_alt_value) && length(max_alt_unit) == 0
            max_alt_unit = "m"
        end    
    else
        max_alt_value = missing
        max_alt_unit = ""
    end

    max_alt = MaxAlt(max_alt_value, max_alt_unit)

    return H_record_PressureAltitudeSensor(source,
        manufacturer,
        model,
        max_alt
    )
end

function parse(::Type{H_record_CompetitionId}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.CIDCOMPETITIONID: ?(.*)"i
    m = match(pattern, line)
    s = strip(m[1])
    return H_record_CompetitionId(source, s)
end

function parse(::Type{H_record_CompetitionClass}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.CCLCOMPETITIONCLASS: ?(.*)"i
    m = match(pattern, line)
    s = strip(m[1])
    return H_record_CompetitionClass(source, s)
end

function parse(::Type{H_record_TimeZoneOffset}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.TZNTIMEZONE: ?(.*)"i
    m = match(pattern, line)
    h = string(strip(m[1]))
    if occursin(".", h)
        h, m = split(h, ".")
        h = parse(Int64, h)
        m = rpad(m, 2, "0")
        m = sign(h) * parse(Int64, m)
    else
        h = parse(Int64, h)
        m = 0
    end
    minutes = round(Int, h * 60 + m)
    return H_record_TimeZoneOffset(minutes, source=source)
end

function parse(::Type{H_record_MeansOfPropulsion}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.MOPSENSOR: ?(.*)"i
    m = match(pattern, line)
    s = m[1]
    return H_record_MeansOfPropulsion(source, s)
end

function parse(::Type{H_record_Site}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.SITSite: ?(.*)"i
    m = match(pattern, line)
    s = m[1]
    return H_record_Site(source, s)
end

function parse(::Type{H_record_UnitsOfMeasure}, line::String)
    line = strip(line)
    source = line[2]
    pattern = r"H.UNTUnits: ?(.*)"i
    m = match(pattern, line)
    s = m[1]
    return H_record_UnitsOfMeasure(source, split(s, ","))
end

const D_TLC_H_RECORD = Dict(
    "DTE" => H_record_DaTE,
    "FXA" => H_record_FiXAccuracy,
    "PLT" => H_record_PiLoT,
    "CM2" => H_record_Copilot,
    "GTY" => H_record_GliderType,
    "GID" => H_record_GliderRegistration,
    "DTM" => H_record_GpsDatum,
    "RFW" => H_record_FirmwareRevision,
    "RHW" => H_record_HardwareRevision,
    "FTY" => H_record_ManufacturerModel,
    "GPS" => H_record_GpsReceiver,
    "PRS" => H_record_PressureAltitudeSensor,
    "CID" => H_record_CompetitionId,
    "CCL" => H_record_CompetitionClass,
    "TZN" => H_record_TimeZoneOffset,
    "MOP" => H_record_MeansOfPropulsion,
    "SIT" => H_record_Site,
    "TZO" => H_record_TimeZoneOffset,
    "UNT" => H_record_UnitsOfMeasure
)

function parse(::Type{Abstract_H_record}, line::String)
    @assert line[1] == 'H'

    # three letter code
    tlc = line[3:5]

    try
        T_H_record = D_TLC_H_RECORD[tlc]
        value = parse(T_H_record, line)
        return value
    catch e
        if isa(e, KeyError)
            throw(ArgumentError("Invalid h-record '$(strip(line))'"))
        else
            throw(e)
        end
    end
end

# ========================================

function parse(::Type{K_record}, line::String)
    @assert line[1] == 'K'
    line = string(strip(line))
    time = parse(Time, line[2:7], IGCTimeFormat)
    value_string = line[8:end]
    start_index = 7
    return K_record(
        time,
        value_string,
        start_index
    )
end

function parse(::Type{L_record}, line::String)
    @assert line[1] == 'L'
    line = strip(line)
    source = line[2:4]
    comment = line[5:end]
    return L_record(
        source,
        comment
    )
end

# ========================================

function parse(::Type{Vector{Abstract_IGC_record}}, s, sep=EOL_DEFAULT)
    return parse.(Abstract_IGC_record, string.(split(s, sep)))
end

# ========================================

function update(record::B_record, fix_record_extensions::AbstractExtensionsRecord)
    # process/update record with fix record extensions

    i = record.start_index_extensions
    ext = record.extensions_string

    for extension in fix_record_extensions.extensions
        start_byte, end_byte = extension.bytes
        start_byte = start_byte - i - 1
        end_byte = end_byte - i - 1

        update(record, extension)

    end

    new_record = B_record(
        record.time,
        record.latitude,
        record.longitude,
        record.validity,
        record.pressure_alt,
        record.gps_alt,
        -1,  # start_index_extensions
        "",  # extensions_string
        IGCExtension[]
    )

    return new_record
end

function update(record::B_record, extension::IGCExtension)
    # todo
    #record.update(
    #    {extension['extension_type']: int(ext[start_byte:end_byte + 1])}
    #)
end

# ========================================

function read(fname::AbstractString, ::Type{IGCDocument}; parsing_mode=ParsingMode.DEFAULT)
    stream = open(fname)
    return parse(IGCDocument, stream, parsing_mode=parsing_mode)
end

function parse(::Type{IGCDocument}, s; parsing_mode=ParsingMode.DEFAULT)
    stream = IOBuffer(s)
    return parse(IGCDocument, stream::IO, parsing_mode=parsing_mode)
end

function parse(::Type{Abstract_IGC_record}, line::String)
    line = string(line)
    record_char = uppercase(line[1])
    T_record = D_RECORD_CHAR[record_char]
    return parse(T_record, line)
end

# ========================================

function update!(igcdoc::IGCDocument, rec::A_record)
    fieldname = :logger_id
    if isempty(getfield(igcdoc, fieldname))
        setfield!(igcdoc, fieldname, rec)
        write(igcdoc.stream, rec)
    else
        throw(IGCNonUniqueRecordException("Non-unique $(typeof(rec)) prev: $(getfield(igcdoc, fieldname)) new: $rec"))
    end
end

#=
function update!(igcdoc::IGCDocument, rec::B_record)
    push!(igcdoc.fix_records, rec)
end

function update!(igcdoc::IGCDocument, rec::G_record)
    push!(igcdoc.security_records, rec)
end
=#

function update!(igcdoc::IGCDocument, rec::T) where {T <: Abstract_H_record}
    fieldname = D_HEADER_RECORD_FIELD[T]
    if igcdoc.parsing_mode == ParsingMode.STRICT && !ismissing(getfield(igcdoc.header, fieldname))
        msg = "Non-unique $(typeof(rec)) prev: $(getfield(igcdoc.header, fieldname)) new: $rec"
        exc = IGCParseException(msg)
        throw(exc)
    end
    setfield!(igcdoc.header, fieldname, rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, rec::H_record_DaTE)
    fieldname = :date
    if igcdoc.parsing_mode == ParsingMode.STRICT && !ismissing(getfield(igcdoc.header, fieldname))
        msg = "Non-unique $(typeof(rec)) prev: $(getfield(igcdoc.header, fieldname)) new: $rec"
        exc = IGCParseException(msg)
        throw(exc)
    end
    #dt = ZonedDateTime(DateTime(rec.value), TZ)
    #igcdoc.dt_first = dt
    #igcdoc.dt_last = dt
    setfield!(igcdoc.header, fieldname, rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, rec::C_record_task_info)
    task = Task(rec)
    # push!(igcdoc.tasks, task)
    igcdoc.task = task
    #dt = ZonedDateTime(task.info.declaration, TZ)
    #if dt > igcdoc.dt_last
    #    igcdoc.dt_last = dt
    #end
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, rec::C_record_waypoint_info)
    #task = igcdoc.tasks[end]
    task = igcdoc.task
    push!(task.waypoints, rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, records::Vector{C_record_waypoint_info})
    for rec in records
        update!(igcdoc, rec)
    end
end

# timestamped record
function update!(igcdoc::IGCDocument, rec::T) where {T <: Union{B_record, E_record, F_record, K_record}}
    fieldname = D_RECORD_FIELD[T]
    #current_date = Date(DateTime(igcdoc.dt_last))
    #last_time = Time(DateTime(igcdoc.dt_last))
    #if rec.time < last_time
    #    dt = ZonedDateTime(current_date + Dates.day(1) + rec.time, TZ)
    #else
    #    dt = ZonedDateTime(current_date + rec.time, TZ)
    #end
    push!(getfield(igcdoc, fieldname), rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
    #println("$dt $(igcdoc.dt_last)")
    #igcdoc.dt_last = dt
end


function update!(igcdoc::IGCDocument, rec::T) where {T <: Union{D_record, G_record, L_record}}
    fieldname = D_RECORD_FIELD[T]
    push!(getfield(igcdoc, fieldname), rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, rec::T) where {T <: Union{I_record, J_record}}
    fieldname = D_RECORD_FIELD[T]
    setfield!(igcdoc, fieldname, rec)
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

#=
function update!(igcdoc::IGCDocument, rec::I_record)
    igcdoc.fix_record_extensions = rec
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end

function update!(igcdoc::IGCDocument, rec::J_record)
    igcdoc.k_record_extensions = rec
    write(igcdoc.stream, igcdoc.eol)
    write(igcdoc.stream, rec)
end
=#

# ========================================

function update!(igcdoc::IGCDocument, records::Vector{T}) where {T <: Abstract_IGC_record}
    for rec in records
        update!(igcdoc, rec)
    end
end

# ========================================

function parse(::Type{IGCDocument}, stream::IO; parsing_mode=ParsingMode.STRICT)
    igcdoc = IGCDocument(parsing_mode=parsing_mode)
    for (line_id, line) in enumerate(eachline(stream))
        try
            rec = parse(Abstract_IGC_record, line)
            update!(igcdoc, rec)
        catch e
            exc = IGCParseException(line_id, line, e)
            if parsing_mode == ParsingMode.UNSTRICT
                push!(igcdoc.errors, exc)
            else
                throw(exc)
            end
        end
    end
    return igcdoc
end
