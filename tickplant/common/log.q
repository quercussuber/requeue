if[`log in key`.;:(`log_already_loaded)];
\d .log
LEVELS:`info`warning`error`debug

// Use 
// info when you want to log high level state and flow information
// warning when you want to log messages that indicates non-ideal state or potential problems
// error when you want to log meesages that indicate a non-recoverable error
// debug when you want to log a debug message
level: `info

logmsg:{[level;msg]
    if[11h = type msg; msg:string msg];
    0N!string[.z.P]," ",upper[string level]," ",msg;
  }

logInfo:logmsg[`info]
logWarning:logmsg[`warning]
logError:logmsg[`error]
logDebug:logmsg[`debug]

// TODO be nice to have both stdout/stderr and file logging
// and also only print to stdout if the level is lower than set up
\d .