string(d::Date, ::Type{IGCDateFormat}) = Dates.format(d, IGC_DATE_FMT)
string(t::Time, ::Type{IGCTimeFormat}) = Dates.format(t, IGC_TIME_FMT)

string(dt::ZonedDateTime, ::Type{IGCTimeFormat}) = string(Time(DateTime(dt)), IGCTimeFormat)
string(dt::ZonedDateTime, ::Type{IGCDateFormat}) = string(Date(DateTime(dt)), IGCDateFormat)

function string(lat::IGCLatitude)
    ordinal = lat.value < 0 ? 'S' : 'N'
    (d, m) = divrem(abs(lat.value), 1)
    d = lpad(round(Int, d), 2, "0")
    m = lpad(round(Int, m * 60 * 1000), 5, "0")
    return "$d$m$ordinal"
end

function write(stream::IO, lat::IGCLatitude)
    write(stream, string(lat))
end

function string(long::IGCLongitude)
    ordinal = long.value < 0 ? 'W' : 'E'
    (d, m) = divrem(abs(long.value), 1)
    d = lpad(round(Int, d), 3, "0")
    m = lpad(round(Int, m * 60 * 1000), 5, "0")
    return "$d$m$ordinal"
end

function write(stream::IO, long::IGCLongitude)
    return write(stream, string(long))
end

function string(alt::T) where {T <: Union{IGCPressureAltitude, IGCGpsAltitude}}
    digits = 5
    if (alt.value < 10^digits) && (alt.value >=0)
        return lpad(alt.value, digits, "0")
    else
        throw(IGCWriteException("Can't output $alt to $digits digits string"))
    end
end

function write(stream::IO, alt::T) where {T <: Union{IGCPressureAltitude, IGCGpsAltitude}}
    return write(stream, string(alt))
end

function string(rec::A_record)
    s = "A" * rec.manufacturer * rec.id
    if length(rec.id_addition) > 0
        s *= " " * rec.id_addition
    end
    return s
end

function string(rec::B_record)
    s = "B"
    s = s * string(rec.time, IGCTimeFormat)
    s = s * string(rec.latitude)
    s = s * string(rec.longitude)
    s = s * FixValidity.string(rec.validity)
    s = s * string(rec.pressure_alt)
    s = s * string(rec.gps_alt)
    s = s * string(rec.extensions_string)
    return s
end

function string(rec::C_record_task_info)
    s = "C"
    s = s * string(rec.declaration.date, IGCDateFormat)
    s = s * string(rec.declaration.time, IGCTimeFormat)
    s = s * string(rec.flight_date, IGCDateFormat)

    s = s * string(rec.number)

    digits = 2
    if (rec.num_turnpoints < 10 ^ digits) && (rec.num_turnpoints >= 0)
        s = s * lpad(rec.num_turnpoints, digits, "0")
    else
        throw(IGCWriteException("Can't write C record (task info) num_turnpoints $(rec.num_turnpoints)"))
    end

    if length(rec.description) > 0
        s = s * " " * rec.description
    end

    return s
end

function string(rec::C_record_waypoint_info)
    s = "C"

    s = s * string(rec.latitude)
    s = s * string(rec.longitude)

    if length(rec.description) > 0
        s = s * " " * rec.description
    end

    return s
end

function string(rec::D_record)
    s = "D"

    s = s * GpsQualifier.string(rec.qualifier)
    s = s * rec.station_id

    return s
end

function string(rec::E_record)
    s = "E"

    s = s * string(rec.time, IGCTimeFormat)
    s = s * rec.tlc
    s = s * rec.extension_string

    return s
end

function string(rec::F_record)
    s = "F"

    s = s * string(rec.time, IGCTimeFormat)

    for satellite in rec.satellites
        s = s * satellite
    end

    return s
end

function string(rec::G_record)
    s = "G"

    s = s * rec.value

    return s
end

function string(rec::T) where {T <: Union{I_record, J_record}}
    s = flc(rec)

    s = s * lpad(length(rec.extensions), 2, "0")

    for extension in rec.extensions
        s = s * lpad(extension.bytes.start, 2, "0")
        s = s * lpad(extension.bytes.stop, 2, "0")
        s = s * extension.type
    end

    return s
end

function string(rec::K_record)
    s = "K"
    s = s * string(rec.time, IGCTimeFormat)
    s = s * rec.value_string
    return s
end

function string(rec::L_record)
    s = "L"
    s = s * rec.source[1:3]
    s = s * rec.comment
    return s
end

# ToDo... write all H records
function string_fr_header(source::Char, tlc::String, value; subtype_long="")
    s = "H"
    s = s * source
    s = s * tlc
    if length(subtype_long) > 0
        s = s * subtype_long * ":"
    end
    s = s * string(value)
    return s
end

function write_fr_header(stream::IO, source::Char, tlc::String, value; subtype_long="")
    return write(stream, string_fr_header(source, tlc, value, subtype_long=subtype_long))
end

function string(rec::H_record_FiXAccuracy)
    return string_fr_header(rec.source, tlc(rec), lpad(rec.value, 3, "0"))
end

function string(rec::H_record_DaTE)
    return string_fr_header(rec.source, tlc(rec), string(rec.value, IGCDateFormat))
end

function string(rec::T) where {T <: Union{H_record_PiLoT, H_record_Copilot, H_record_GliderType, H_record_GliderRegistration, H_record_GpsDatum, H_record_FirmwareRevision, H_record_HardwareRevision, H_record_CompetitionId, H_record_CompetitionClass, H_record_MeansOfPropulsion, H_record_Site}}
    return string_fr_header(rec.source, tlc(rec), rec.value, subtype_long=subtype_long(rec))
end

function string(rec::H_record_ManufacturerModel)
    return string_fr_header(rec.source, tlc(rec),
        join([rec.manufacturer, rec.model], ","),
        subtype_long=subtype_long(rec)    
    )
end

function string(rec::H_record_GpsReceiver)
    return string_fr_header(rec.source, tlc(rec),
        ":" * join([rec.manufacturer,
            rec.model, 
            ismissing(rec.channels) ? "" : "$(rec.channels)ch",
            ismissing(rec.max_alt.value) ? "" : "max$(rec.max_alt.value)$(rec.max_alt.unit)"]
        , ",")
    )
end

function string(rec::H_record_PressureAltitudeSensor)
    return string_fr_header(rec.source, tlc(rec),
        join([rec.manufacturer,
            rec.model, 
            ismissing(rec.max_alt.value) ? "" : "max$(rec.max_alt.value)$(rec.max_alt.unit)"]
        , ","),
        subtype_long=subtype_long(rec)
    )
end

function string(rec::H_record_UnitsOfMeasure)
    return string_fr_header(rec.source, tlc(rec),
        join(rec.value, ","),
        subtype_long=subtype_long(rec)
    )
end

function string(rec::H_record_TimeZoneOffset)
    (h, m) = divrem(rec.value.offset.std, 60 * Dates.Second(60))
    m = abs(div(m, Dates.Second(60)))
    if m == 0
        s = "$h"
    else
        s = "$h.$(lpad(m, 2, "0"))"
    end
    return string_fr_header(rec.source, tlc(rec),
        s, subtype_long=subtype_long(rec))
end

function write(stream::IO, task::Task)
    write(stream, task.info)
    for wpt in task.waypoints
        write(stream, wpt)
    end
end

function write(stream::IO, rec::T) where {T <: Abstract_IGC_record}
    return write(stream, string(rec))
end

# ========================================

function write(stream::IO, header::Header; eol=EOL_DEFAULT)
    if !ismissing(header.fix_accuracy)
        write(stream, header.fix_accuracy)
        write(stream, eol)
    end

    write(stream, header.date)
    write(stream, eol)
    write(stream, header.pilot_in_charge)
    write(stream, eol)
    write(stream, header.crew2)
    write(stream, eol)
    write(stream, header.glider_type)
    write(stream, eol)
    write(stream, header.glider_id)
    write(stream, eol)
    write(stream, header.gps_datum)
    write(stream, eol)
    write(stream, header.firmware_version)
    write(stream, eol)
    write(stream, header.hardware_version)
    write(stream, eol)
    write(stream, header.flight_recorder_type)
    write(stream, eol)
    write(stream, header.gps_receiver)
    write(stream, eol)
    write(stream, header.pressure_altitude_sensor)

    if !ismissing(header.competition_id)
        write(stream, eol)
        write(stream, header.competition_id)
    end    

    if !ismissing(header.competition_class)
        write(stream, eol)
        write(stream, header.competition_class)
    end    

end

# ========================================

function write(stream::IO, records::Vector{T}) where {T <: Union{B_record, D_record, E_record, F_record, L_record, G_record}}
    for rec in records
        write(stream, rec)
    end
end

# ========================================

function write(stream::IO, igcdoc::IGCDocument; eol=EOL_DEFAULT)
    # A record
    write(stream, igcdoc.logger_id)
    write(stream, eol)
    
    # H records
    # @assert iscomplete(igcdoc.header)
    write(stream, igcdoc.header, eol=eol)

    # I records
    if length(igcdoc.fix_record_extensions.extensions) > 0
        write(stream, eol)
        write(stream, igcdoc.fix_record_extensions)
    end

    # J records
    if length(igcdoc.k_record_extensions.extensions) > 0
        write(stream, eol)
        write(stream, igcdoc.k_record_extensions)
    end
        
    # C records
    if have_task_declared(igcdoc)
        write(stream, igcdoc.task)
    end

    #= flight =#

    # F records
    if length(igcdoc.satellite_records) > 0
        write(stream, igcdoc.satellite_records)
    end

    # B records
    if length(igcdoc.fix_records) > 0
        write(stream, igcdoc.fix_records)
    end

    # D records
    if length(igcdoc.dgps_records) > 0
        write(stream, igcdoc.dgps_records)
    end

    # E records
    if length(igcdoc.event_records) > 0
        write(stream, igcdoc.event_records)
    end

    #= at end =#

    # L records
    if length(igcdoc.comment_records) > 0
        write(stream, igcdoc.comment_records)
    end

    # G records
    if length(igcdoc.security_records) > 0
        write(stream, igcdoc.security_records)
    end
end

#=
    logger_id::A_record
    fix_records::Vector{B_record}
    tasks::Vector{Task}
    dgps_records::Vector{D_record}
    event_records::Vector{E_record}
    satellite_records::Vector{F_record}
    security_records::Vector{G_record}
    header::Header
    fix_record_extensions::Vector{I_record}
    k_record_extensions::Vector{J_record}
    k_records::Vector{K_record}
    comment_records::Vector{L_record}
    errors::Vector{IGCParseException}
=#