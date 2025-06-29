local enabled = ar_config.plugin.custom.recording_studio.enable

if not ar or ar.none or not enabled then return end

local L = vim.log.levels
local fn = vim.fn

local config = {
  output_dir = vim.env.HOME .. '/Recordings',
  video_format = 'mp4',
  audio_format = 'm4a',
  fps = 60,
  screen_resolution = '1366x768', -- '1920x1080'
  input_format = 'x11grab',
  video_input = ':0.0',
  audio_input = 'default',
  combined_input = ':0.0',
}

local jobs = { video = nil, audio = nil }

fn.mkdir(config.output_dir, 'p')

local current_file = ''

local function get_timestamp() return os.date('%Y%m%d_%H%M%S') end

local function notify(msg, level, opts)
  opts = opts or {}
  opts.title = opts.title or 'Recording Studio'
  vim.notify(msg, level or L.INFO, opts)
end

local function get_filename(format, filename)
  if not filename or filename == '' then
    return 'Recording_' .. get_timestamp() .. '.' .. format
  end
  if filename:match('%.' .. format .. '$') then return filename end
  return filename .. '.' .. format
end

local function get_video_input_args(filepath)
  local args = { '-framerate', tostring(config.fps), '-f', config.input_format }
  if config.input_format == 'x11grab' then
    vim.list_extend(args, { '-s', config.screen_resolution })
  elseif config.input_format == 'gdigrab' then
    vim.list_extend(args, { '-framerate', tostring(config.fps) })
  end
  vim.list_extend(args, { '-i', config.video_input, filepath })
  return args
end

local function get_audio_input_args()
  local args = {}
  vim.list_extend(args, { '-f', 'alsa', '-i', config.audio_input })
  return args
end

local function run_command(job, cmd, filename)
  jobs[job] = fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        if ar_config.debug.enable then
          notify(job .. ' recording exited with error: ' .. exit_code, L.ERROR)
        end
      end
      jobs[job] = nil
    end,
  })

  if jobs[job] <= 0 then
    notify('Failed to start' .. job .. ' recording: ' .. filename, L.ERROR)
    jobs[job] = nil
  else
    notify(job .. ' recording started: ' .. filename, L.INFO)
  end
end

local function start_video(filename)
  if jobs.video then
    notify('Video recording already in progress!', L.WARN)
    return
  end

  filename = get_filename(config.video_format, filename)
  local filepath = config.output_dir .. '/' .. filename
  current_file = filepath

  local record_cmd = { 'ffmpeg' }
  vim.list_extend(record_cmd, get_video_input_args(filepath))
  vim.list_extend(record_cmd, { '-y', filepath }) -- -y to overwrite existing files

  if ar_config.debug.enable then
    print('Record command: ' .. vim.inspect(record_cmd))
  end

  run_command('video', record_cmd, filename)
end

local function start_audio(filename)
  if jobs.audio then
    notify('Audio recording already in progress!', L.WARN)
    return
  end

  filename = get_filename(config.audio_format, filename)
  local filepath = config.output_dir .. '/' .. filename
  current_file = filepath

  local audio_cmd = { 'ffmpeg' }
  vim.list_extend(audio_cmd, get_audio_input_args())
  vim.list_extend(audio_cmd, { '-c:a', 'aac', '-b:a', '128k', filepath })

  if ar_config.debug.enable then
    print('Audio command: ' .. vim.inspect(audio_cmd))
  end

  run_command('audio', audio_cmd, filename)
end

local function stop_recording()
  local stopped = {}

  if jobs.video then
    fn.jobstop(jobs.video)
    jobs.video = nil
    table.insert(stopped, 'video')
  end

  if jobs.audio then
    fn.jobstop(jobs.audio)
    jobs.audio = nil
    table.insert(stopped, 'audio')
  end

  if #stopped > 0 then
    -- notify('Stopped ' .. table.concat(stopped, ' and ') .. ' recording', L.INFO)
    if current_file ~= '' then notify('Saved to: ' .. current_file, L.INFO) end
  else
    notify('No recording in progress', L.WARN)
  end
  current_file = ''
end

ar.command('RecordingStartVideo', function(args)
  local filename = vim.trim(args.args or '')
  start_video(filename)
end, {
  nargs = '?',
  desc = 'Start video recording with optional filename',
})
ar.command('RecordingStartAudio', function(args)
  local filename = vim.trim(args.args or '')
  start_audio(filename)
end, {
  nargs = '?',
  desc = 'Start audio recording with optional filename',
})
ar.command('RecordingStop', stop_recording, { nargs = 0 })
