class_name Log extends Logger

enum Event {
	CONNECTION,
	INFO,
	WARN,
	ERROR,
	CRITICAL,
}

const EVENT_COLORS: Dictionary[Event, String] = {
	Event.CONNECTION: "grey",
	Event.INFO: "lime_green",
	Event.WARN: "gold",
	Event.ERROR: "tomato",
	Event.CRITICAL: "crimson",
}

const _FLUSH_EVENTS: PackedByteArray = [
	Event.ERROR,
	Event.CRITICAL,
]

static var _mutex := Mutex.new()

static var _event_strings: PackedStringArray = Event.keys()

const _LOG_DIR := "user://"
const _LOG_EXTENSION := "log"

const _MAX_LOG_FILES: int = 5
const _MAX_BUFFER_SIZE: int = 10

static var _buffer_size: int

static var _log_file: FileAccess
static var _is_valid: bool

static func _static_init() -> void:
	_log_file = _create_log_file()
	_is_valid = _log_file and _log_file.is_open()
	if _is_valid:
		OS.add_logger(Log.new())
		_remove_old_log_files()

static func _remove_old_log_files() -> void:
	var log_file_paths: Array[String]
	for file: String in DirAccess.get_files_at(_LOG_DIR):
		if file.get_extension().to_lower() == _LOG_EXTENSION:
			log_file_paths.append(_LOG_DIR.path_join(file))
	while log_file_paths.size() > _MAX_LOG_FILES:
		var path: String = log_file_paths.pop_front()
		var err := DirAccess.remove_absolute(path)
		if err:
			error("Failed to clean up old log (%s): %s" % [error_string(err), path])
		else:
			info("Cleaned up old log: %s" % path)

static func _create_log_file() -> FileAccess:
	var file_name := "%s.%s" % [Time.get_datetime_string_from_system(), _LOG_EXTENSION]
	var file_path := _LOG_DIR.path_join(file_name)
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	
	var run_info : String = "## Song of MaeLOG ##\n"
	
	run_info += "Build: "
	run_info += ProjectSettings.get_setting("application/config/version")
	if OS.has_feature("web"):
		run_info += " (WEB)"
	if OS.has_feature("debug"):
		run_info += " (DEBUG)"
	
	# Storing some useful data
	run_info += "\n"
	run_info += "Execution Time: " + Time.get_datetime_string_from_system() + "\n"
	run_info += "Running on " + Engine.get_version_info()["string"] + "\n"
	run_info += "Args: " + str(OS.get_cmdline_args()) + "\n"
	run_info += "-----------------------------"
	file.store_line(run_info)
	
	return file

static func _add_message_to_file(message: String, event: Event) -> void:
	_mutex.lock()
	if _is_valid:
		if not message.is_empty():
			_is_valid = _log_file.store_line(message)
			_buffer_size += 1
		if _buffer_size >= _MAX_BUFFER_SIZE or event in _FLUSH_EVENTS:
			_log_file.flush()
			_buffer_size = 0
	_mutex.unlock()

#region Helpers
static func _get_gdscript_backtrace(script_backtraces: Array[ScriptBacktrace]) -> String:
	var gdscript := script_backtraces.find_custom(func(backtrace: ScriptBacktrace) -> bool:
		return backtrace.get_language_name() == "GDScript")
	return "Backtrace N/A" if gdscript == -1 else str(script_backtraces[gdscript])

static func _format_log_message(message: String, event: Event) -> String:
	return "[{time}] {event}: {message}".format({
		"time": Time.get_time_string_from_system(),
		"event": _event_strings[event],
		"message": message,
	})
#endregion

static func _print_event(message: String, event: Event) -> void:
	var message_lines := message.split("\n")
	message_lines[0] = "[b][color=%s]%s[/color][/b]" % [EVENT_COLORS[event], message_lines[0]]
	print_rich.call_deferred("[lang=tlh]%s[/lang]" % "\n".join(message_lines))

@warning_ignore("unused_parameter")
func _log_error(
	function: String, 
	file: String, 
	line: int, 
	code: String, 
	rationale: String, 
	editor_notify: bool, 
	error_type: int, 
	script_backtraces: Array[ScriptBacktrace]
) -> void:
	if not _is_valid:
		return
	var event := Event.WARN if error_type == ERROR_TYPE_WARNING else Event.ERROR
	var message := "[{time}] {event}: {rationale}\n{code}\n{file}:{line} @ {function}()".format({
		"time": Time.get_time_string_from_system(),
		"event": _event_strings[event],
		"rationale": rationale,
		"code": code,
		"file": file,
		"line": line,
		"function": function,
 	})
	_add_message_to_file(message, event)

func _log_message(message: String, is_error: bool) -> void:
	if not _is_valid:
		return
	var event := Event.ERROR if is_error else Event.INFO
	message = _format_log_message(message.trim_suffix('\n'), event)
	_add_message_to_file(message, event)

static func connection(message: String) -> void:
	if not _is_valid:
		return
	var event := Event.CONNECTION
	message = _format_log_message(message, event)
	_add_message_to_file(message, event)
	_print_event(message, event)

static func info(message: String) -> void:
	if not _is_valid:
		return
	var event := Event.INFO
	message = _format_log_message(message, event)
	_add_message_to_file(message, event)
	_print_event(message, event)

static func warn(message: String) -> void:
	if not _is_valid:
		return
	var event := Event.WARN
	message = _format_log_message(message, event)
	_add_message_to_file(message, event)
	_print_event(message, event)

static func error(message: String) -> void:
	if not _is_valid:
		return
	var event := Event.ERROR
	message = _format_log_message(message, event)
	var script_backtraces := Engine.capture_script_backtraces()
	message += '\n' + _get_gdscript_backtrace(script_backtraces)
	_add_message_to_file(message, event)
	_print_event(message, event)

static func critical(message: String) -> void:
	if not _is_valid:
		return
	var event := Event.CRITICAL
	message = _format_log_message(message, event)
	var script_backtraces := Engine.capture_script_backtraces()
	message += '\n' + _get_gdscript_backtrace(script_backtraces)
	_add_message_to_file(message, event)
	_print_event(message, event)
