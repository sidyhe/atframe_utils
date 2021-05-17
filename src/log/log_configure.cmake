# Lua模块
if(LOG_WRAPPER_ENABLE_LUA_SUPPORT AND LOG_WRAPPER_CHECK_LUA)
  if(TARGET lua::liblua-dynamic)
    list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua::liblua-dynamic)
  elseif(TARGET lua::liblua-static)
    list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua::liblua-static)
  elseif(TARGET lua)
    list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua)
  else()
    set(LOG_WRAPPER_ENABLE_LUA_SUPPORT OFF)
    message(STATUS "Lua not found and disabled.")
  endif()
endif()

# traceback 检测 gcc可能需要加 -funwind-tables 选项，尽可能不要用 -fvisibility=hidden Android下需要 APP_STL := gnustl_static or
# gnustl_shared
if(LOG_WRAPPER_ENABLE_STACKTRACE)
  if(LIBUNWIND_ENABLED)
    if(Libunwind_FOUND AND Libunwind_HAS_UNW_INIT_LOCAL)
      set(LOG_STACKTRACE_USING_LIBUNWIND 1)
      if(TARGET Libunwind::libunwind)
        if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
          echowithcolor(
            COLOR GREEN
            "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Private Link).")
          list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_LINK_NAMES Libunwind::libunwind)
        else()
          echowithcolor(COLOR GREEN
                        "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Public Link).")
          list(APPEND PROJECT_ATFRAME_UTILS_PUBLIC_LINK_NAMES Libunwind::libunwind)
        endif()
      else()
        if(Libunwind_LIBRARIES)
          if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
            echowithcolor(
              COLOR GREEN
              "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Private Link).")
            list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_LINK_NAMES ${Libunwind_LIBRARIES})
          else()
            echowithcolor(
              COLOR GREEN
              "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Interface Link).")
            list(APPEND PROJECT_ATFRAME_UTILS_INTERFACE_LINK_NAMES ${Libunwind_LIBRARIES})
          endif()
        endif()
        if(Libunwind_INCLUDE_DIRS)
          list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_INCLUDE_DIRS ${Libunwind_INCLUDE_DIRS})
        endif()
      endif()
    else()
      if(NOT Libunwind_FOUND)
        echowithcolor(COLOR YELLOW "-- Stacktrace: LIBUNWIND_ENABLED=YES but we can not find libunwind.")
      else()
        echowithcolor(COLOR YELLOW "-- Stacktrace: LIBUNWIND_ENABLED=YES but unw_init_local disabled.")
      endif()
    endif()
  endif()

  if(NOT LOG_STACKTRACE_USING_LIBUNWIND)
    include(CheckIncludeFiles)
    if(WIN32
       OR CYGWIN
       OR MINGW)
      check_include_files("Windows.h;DbgHelp.h" LOG_STACKTRACE_DBG_HELP_DIR)
      if(LOG_STACKTRACE_DBG_HELP_DIR)
        set(LOG_STACKTRACE_USING_DBGHELP 1)
        echowithcolor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_DBGHELP=${LOG_STACKTRACE_USING_DBGHELP}.")
      else()
        check_include_files("Windows.h;DbgEng.h" LOG_STACKTRACE_DBG_ENG_DIR)
        if(LOG_STACKTRACE_DBG_ENG_DIR)
          set(LOG_STACKTRACE_USING_DBGENG 1)
          echowithcolor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_DBGENG=${LOG_STACKTRACE_USING_DBGENG}.")
        else()
          echowithcolor(COLOR YELLOW "-- Stacktrace: Can not find DbgHelp.h or DbgEng.h, disable it.")
        endif()
      endif()
    elseif(UNIX)
      check_include_files(execinfo.h LOG_STACKTRACE_EXECINFO_DIR)
      if(LOG_STACKTRACE_EXECINFO_DIR)
        set(LOG_STACKTRACE_USING_EXECINFO 1)
        echowithcolor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_EXECINFO=${LOG_STACKTRACE_USING_EXECINFO}.")
      else()
        check_include_files(unwind.h LOG_STACKTRACE_UNWIND_DIR)
        if(LOG_STACKTRACE_UNWIND_DIR)
          set(LOG_STACKTRACE_USING_UNWIND 1)
          echowithcolor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_UNWIND=${LOG_STACKTRACE_USING_UNWIND}.")
        else()
          echowithcolor(COLOR YELLOW "-- Stacktrace: Can not find execinfo.h or unwind.h, disable it.")
        endif()
      endif()
    else()
      echowithcolor(COLOR YELLOW "-- Stacktrace: Unsupportedd for stacktrace, disable it.")
    endif()
  endif()
endif()
