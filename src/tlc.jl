# TLC = Three Letters Code

const TLC = Dict(
    "ACX" => :linear_acceleration_x,
    "ACY" => :linear_acceleration_y,
    "ACZ" => :linear_acceleration_z,
    "ANX" => :angular_acceleration_x,
    "ANY" => :angular_acceleration_y,
    "ABZ" => :angular_acceleration_z,  # ABZ? not ANZ?
    "ATS" => :altimeter_pressure,
    "BEI" => :gnss_beidou,
    "BFI" => :blind_flying_instrument,
    "CCL" => :competition_class,
    "CGD" => :change_geodetic_datum,
    "CID" => :competition_id,
    "CLB" => :club,
    "CM2" => :second_crew_member,
    "COT" => :controller_temperature,
    "CUR" => :electrical_current,
    "DAE" => :displacement_east,
    "DAN" => :displacement_north,
    "DB1" => :date_of_birth_pilot_in_charge,
    "DB2" => :date_of_birth_second_crew_member,
    "DTE" => :date,
    "DTM" => :geodetic_datum,
    "EGT" => :exhaust_gas_temperature,
    "FLE" => :fuel_level,
    "FFL" => :fuel_flow,
    "ENL" => :environmental_noise_level,
    "FIN" => :finish,
    "FLP" => :flap_position,
    "FRS" => :flight_recorder_security,
    "FTY" => :flight_recorder_type,
    "FXA" => :fix_accuracy,
    "GAL" => :gnss_galileo,
    "GID" => :glider_id,
    "GLO" => :gnss_glonass,
    "GPS" => :gnss_gps,
    "GSP" => :ground_speed,
    "GTY" => :glider_type,
    "HDM" => :heading_magnetic,
    "HDT" => :heading_true,
    "IAS" => :airspeed,
    "JPT" => :jet_pipe_temperature,
    "LEB" => :battery_left,
    "LAD" => :last_places_of_decimal_minutes_of_latitude,
    "LCU" => :data_seeyou_l,
    "LOD" => :last_places_of_decimal_minutes_of_longitude,
    "LOV" => :low_voltage,
    "MAC" => :mac_ready_setting,
    "MCU" => :data_seeyou_m,
    "MP2" => :additional_means_of_propulsion_2,
    "MP3" => :additional_means_of_propulsion_3,
    "MP4" => :additional_means_of_propulsion_4,
    "MP5" => :additional_means_of_propulsion_5,
    "MP6" => :additional_means_of_propulsion_6,
    "MP7" => :additional_means_of_propulsion_7,
    "MP8" => :additional_means_of_propulsion_8,
    "MP9" => :additional_means_of_propulsion_9,
    "MOT" => :motor_temperature,
    "MOP" => :means_of_propulsion,
    "OA1" => :position_other_aircraft_1,
    "OA2" => :position_other_aircraft_2,
    "OA3" => :position_other_aircraft_3,
    "OA4" => :position_other_aircraft_4,
    "OA5" => :position_other_aircraft_5,
    "OA6" => :position_other_aircraft_6,
    "OA7" => :position_other_aircraft_7,
    "OA8" => :position_other_aircraft_8,
    "OA9" => :position_other_aircraft_9,
    "OAT" => :outside_air_temperature,
    "ONT" => :on_task,
    "OOI" => :oo_id,
    "PEV" => :pilot_event,
    "PFC" => :post_flight_claim,
    "PLT" => :pilot_in_charge,
    "PRS" => :pressure_altitude_sensor,
    "RAI" => :receiver_autonomous_integrity_monitoring,
    "REX" => :record_addition,
    "RFW" => :firmware_version,  # of flight recorder
    "RHW" => :hardware_version,  # of flight recorder
    "RPM" => :revolution_per_minute,
    "SEC" => :security,
    "SIT" => :site,
    "SIU" => :satellites_in_use,
    "STA" => :start_event,
    "TAS" => :airspeed_true,
    "TDS" => :utc_time_decimal_seconds,
    "TEN" => :total_energy_altitude,
    "TPC" => :turn_point_confirmation,
    "TRT" => :true_task,
    "TZN" => :timezone_offset,
    "UND" => :undercarriage,  # landing gear
    "VAR" => :uncompensated_variometer,
    "VOL" => :electric_voltage,
    "VAT" => :compensated_variometer,
    "VXA" => :vertical_fix_accuracy,
    "WDI" => :wind_direction,
    "WSP" => :wind_speed,
)

#=
"XN*"
A manufacturer code where N is the manufacturer's single-character IGC name (para A3.5.6) and * is any character.
The manufacturer must specify its meaning and us in the documentation for the recorder and its use must be
approved by GFAC before IGC-approval. The X prefix is intended to allow a trial with a provisional new code
before deciding whether it is worthwhile adding to the full list.
=#

const OBSOLETE_TLC = Dict(
    "CCN" => :camera_connect,
    "CDC" => :camera_disconnect,
    "DOB" => :date_of_birth_pilot,  # now use DB1
    "PHO" => :photo_taken,  # shutter-press
    "SCM" => :second_crew_member,  # now use CM2
)

const OBSOLETE_ENGINE_CODE_TLC = Dict(
    "EDN" => :engine_down,
    "EOF" => :engine_off,
    "EON" => :engine_on,
    "EUP" => :engine_up,
)
