action = ARGV[0]
ssh = ARGV[1]

case action
when "connect"
  `osascript -e '
  tell application "iTerm"
    make new terminal
    tell the current terminal
        activate current session
        launch session "Default Session"
        tell the last session
            write text "ssh #{ssh}"
        end tell
    end tell
  end tell'`
end
