﻿
# Lua模块
if (LOG_WRAPPER_ENABLE_LUA_SUPPORT)
    if (LOG_WRAPPER_CHECK_LUA)
        if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
            if (TARGET lua::liblua-dynamic)
                list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua::liblua-dynamic)
            elseif (TARGET lua)
                list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua)
            else ()
                find_package(Lua)        
                if (LUA_FOUND)
                    list(APPEND PROJECT_ATFRAME_UTILS_PUBLIC_INCLUDE_DIRS ${LUA_INCLUDE_DIR})
                    list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB ${LUA_LIBRARIES})
                    message(STATUS "Lua support enabled.(lua ${LUA_VERSION_STRING} detected)")
                else()
                    set(LOG_WRAPPER_ENABLE_LUA_SUPPORT OFF)
                    message(STATUS "Lua not found and disabled.")
                endif()
            endif()
        else ()
            if (TARGET lua::liblua-static)
                list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua::liblua-static)
            elseif (TARGET lua)
                list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB lua)
            else ()
                find_package(Lua)        
                if (LUA_FOUND)
                    list(APPEND PROJECT_ATFRAME_UTILS_PUBLIC_INCLUDE_DIRS ${LUA_INCLUDE_DIR})
                    list(APPEND PROJECT_ATFRAME_UTILS_EXTENTION_LINK_LIB ${LUA_LIBRARIES})
                    message(STATUS "Lua support enabled.(lua ${LUA_VERSION_STRING} detected)")
                else()
                    set(LOG_WRAPPER_ENABLE_LUA_SUPPORT OFF)
                    message(STATUS "Lua not found and disabled.")
                endif()
            endif()
        endif()
    endif()
endif()

# traceback 检测
# gcc可能需要加 -funwind-tables 选项，尽可能不要用 -fvisibility=hidden
# Android下需要 APP_STL := gnustl_static or gnustl_shared
if (LOG_WRAPPER_ENABLE_STACKTRACE)
    if (LIBUNWIND_ENABLED)
        find_package(Libunwind)
        if (Libunwind_FOUND AND Libunwind_HAS_UNW_INIT_LOCAL)
            set(LOG_STACKTRACE_USING_LIBUNWIND 1)
            if (TARGET Libunwind::libunwind)
                if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
                    EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Private Link).")
                    list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_LINK_NAMES Libunwind::libunwind)
                else()
                    EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Public Link).")
                    list(APPEND PROJECT_ATFRAME_UTILS_PUBLIC_LINK_NAMES Libunwind::libunwind)
                endif()
            else ()
                if (Libunwind_LIBRARIES)
                    if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
                        EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Private Link).")
                        list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_LINK_NAMES ${Libunwind_LIBRARIES})
                    else()
                        EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_LIBUNWIND=${LOG_STACKTRACE_USING_LIBUNWIND}(Interface Link).")
                        list(APPEND PROJECT_ATFRAME_UTILS_INTERFACE_LINK_NAMES ${Libunwind_LIBRARIES})
                    endif()
                endif ()
                if (Libunwind_INCLUDE_DIRS)
                    list(APPEND PROJECT_ATFRAME_UTILS_PRIVATE_INCLUDE_DIRS ${Libunwind_INCLUDE_DIRS})
                endif ()
            endif ()
        else()
            if (NOT Libunwind_FOUND)
                EchoWithColor(COLOR YELLOW "-- Stacktrace: LIBUNWIND_ENABLED=YES but we can not find libunwind.")
            else()
                EchoWithColor(COLOR YELLOW "-- Stacktrace: LIBUNWIND_ENABLED=YES but unw_init_local disabled.")
            endif()
        endif()
    endif()

    if (NOT LOG_STACKTRACE_USING_LIBUNWIND)
        include(CheckIncludeFiles)
        if (WIN32 OR CYGWIN OR MINGW)
            CHECK_INCLUDE_FILES("Windows.h;DbgHelp.h" LOG_STACKTRACE_DBG_HELP_DIR)
            if(LOG_STACKTRACE_DBG_HELP_DIR)
                set(LOG_STACKTRACE_USING_DBGHELP 1)
                EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_DBGHELP=${LOG_STACKTRACE_USING_DBGHELP}.")
            else()
                CHECK_INCLUDE_FILES("Windows.h;DbgEng.h" LOG_STACKTRACE_DBG_ENG_DIR)
                if(LOG_STACKTRACE_DBG_ENG_DIR)
                    set(LOG_STACKTRACE_USING_DBGENG 1)
                    EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_DBGENG=${LOG_STACKTRACE_USING_DBGENG}.")
                else()
                    EchoWithColor(COLOR YELLOW "-- Stacktrace: Can not find DbgHelp.h or DbgEng.h, disable it.")
                endif()
            endif()
        elseif (UNIX)
            CHECK_INCLUDE_FILES(execinfo.h LOG_STACKTRACE_EXECINFO_DIR)
            if(LOG_STACKTRACE_EXECINFO_DIR)
                set(LOG_STACKTRACE_USING_EXECINFO 1)
                EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_EXECINFO=${LOG_STACKTRACE_USING_EXECINFO}.")
            else()
                CHECK_INCLUDE_FILES(unwind.h LOG_STACKTRACE_UNWIND_DIR)
                if(LOG_STACKTRACE_UNWIND_DIR)
                    set(LOG_STACKTRACE_USING_UNWIND 1)
                    EchoWithColor(COLOR GREEN "-- Stacktrace: LOG_STACKTRACE_USING_UNWIND=${LOG_STACKTRACE_USING_UNWIND}.")
                else()
                    EchoWithColor(COLOR YELLOW "-- Stacktrace: Can not find execinfo.h or unwind.h, disable it.")
                endif()
            endif()
        else ()
            EchoWithColor(COLOR YELLOW "-- Stacktrace: Unsupportedd for stacktrace, disable it.")
        endif()
    endif()
endif()