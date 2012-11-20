do

   -- obsolete and incomplete protocol reference:
   -- http://wiki.slimdevices.com/index.php/SlimProto_TCP_protocol

   local p_slim_s = Proto("slim_s", "SLIM-S")
   local dissector = { client = {}, server = {} }

   local fields = {
      client = {
         code = ProtoField.string("slim_s.client.code", "Client Code"),
         len  = ProtoField.uint32("slim_s.client.length", "Length", base.DEC),
         data = ProtoField.bytes("slim_s.client.data", "Data", base.HEX),

         helo = {
            device_id        = ProtoField.uint8("slim_s.client.helo.device_id", "DeviceID", base.DEC),
            revision         = ProtoField.uint8("slim_s.client.helo.revision", "Revision", base.DEC),
            mac              = ProtoField.ether("slim_s.client.helo.mac", "MAC"),
            uuid             = ProtoField.bytes("slim_s.client.helo.uuid", "UUID", base.HEX),
            wlan_channellist = ProtoField.uint16("slim_s.client.helo.wlan_channellist",
                                                 "WLAN channel list", base.HEX),
            bytes_received   = ProtoField.uint64("slim_s.client.helo.bytes_received",
                                                 "Bytes received", base.DEC),
            lang             = ProtoField.string("slim_s.client.helo.lang", "Language"),
            capabilities     = ProtoField.string("slim_s.client.helo.capabilities", "Capabilities"),
      },

         prxy = {
            ip = ProtoField.ipv4("slim_s.client.prxy.ipv4", "IPv4"),
            port = ProtoField.uint16("slim_s.client.prxy.port", "Port"),
         },

         anic = {
            flags = ProtoField.uint8("slim_s.client.anic.flags", "Flags", base.HEX),
         },

         body = {
            data = ProtoField.string("slim_s.client.body.data", "HTTP body data"),
         },

         butn = {
            time = ProtoField.uint32("slim_s.client.butn.time", "Time", base.DEC),
            code = ProtoField.uint32("slim_s.client.butn.code", "Button code", base.HEX),
         },

         bye = {
            code = ProtoField.uint8("slim_s.client.bye.code", "Bye code", base.DEC),
         },

         dbug = {
            data = ProtoField.string("slim_s.client.dbug.data", "Debug data"),
         },

         ir = {
            time    = ProtoField.uint32("slim_s.client.ir.time", "Time since startup (1KHz)", base.DEC),
            format  = ProtoField.uint8("slim_s.client.ir.format", "Format", base.DEC),
            no_bits = ProtoField.uint8("slim_s.client.ir.no_bits", "No bits", base.DEC),
            code    = ProtoField.uint32("slim_s.client.ir.code", "IR code", base.HEX),
         },

         knob = {
            time     = ProtoField.uint32("slim_s.client.knob.time", "Time", base.DEC),
            position = ProtoField.uint32("slim_s.client.knob.position", "Position", base.HEX),
            sync     = ProtoField.uint8("slim_s.client.knob.sync", "Sync", base.DEC),
         },

         meta = {
            data = ProtoField.string("slim_s.client.meta.data", "Metadata"),
         },

         rawi = {
            data = ProtoField.string("slim_s.client.rawi.data", "Raw data"),
         },

         resp = {
            data = ProtoField.string("slim_s.client.resp.data", "HTTP response data"),
         },

         setd = {
            id                      = ProtoField.uint8("slim_s.client.setd.id", "Pref Id", base.DEC),
            playername              = ProtoField.string("sli_s.client.setd.playername", "Player name"),
            digital_output_encoding = ProtoField.uint8("slim_s.client.setd.digital_output_encoding",
                                                       "Digital Output Encoding", base.DEC),
            world_clock_output      = ProtoField.uint8("slim_s.client.setd.world_clock_output",
                                                       "World clock output", base.DEC),
            power_off_dac           = ProtoField.uint8("slim_s.client.setd.power_off_dac",
                                                       "Power off dac", base.DEC),
            disable_dac             = ProtoField.uint8("slim_s.client.setd.disable_dac",
                                                       "Disable dac", base.DEC),
            fxloop_source           = ProtoField.uint8("slim_s.client.setd.fxloop_source",
                                                       "Fxloop source", base.DEC),
            fxloop_clock            = ProtoField.uint8("slim_s.client.setd.fxloop_clock",
                                                       "Fxloop clock", base.DEC),
            unknown_pref            = ProtoField.bytes("slim_s.client.setd.unknown_pref",
                                                       "Unknown pref data"),
         },

         stat = {
            event_code             = ProtoField.string("slim_s.client.stat.event_code", "Event code"),
            num_crlf               = ProtoField.uint8("slim_s.client.stat.num_crlf", "Num CRLF"),
            mas_initialized        = ProtoField.uint8("slim_s.client.stat.mas_initialized", "Mas initialized"),
            mas_mode               = ProtoField.uint8("slim_s.client.stat.mas_mode", "Mas mode"),
            fullness_a             = ProtoField.uint32("slim_s.client.stat.fullness_a", "Fullness A"),
            fullness_b             = ProtoField.uint32("slim_s.client.stat.fullness_b", "Fullness B"),
            bytes_received         = ProtoField.uint64("slim_s.client.stat.bytes_received", "Bytes received"),
            signal_strength        = ProtoField.uint16("slim_s.client.stat.signal_strength", "Signal strength"),
            jiffies                = ProtoField.uint32("slim_s.client.stat.jiffies", "Jiffies"),
            output_buffer_size     = ProtoField.uint32("slim_s.client.stat.output_buffer_size",
                                                       "Output buffer size"),
            output_buffer_fullness = ProtoField.uint32("slim_s.client.stat.output_buffer_fullness",
                                                       "Output buffer fullness"),
            elapsed_seconds        = ProtoField.uint32("slim_s.client.stat.elapsed_seconds", "Elapsed seconds"),
            voltage                = ProtoField.uint16("slim_s.client.stat.voltage", "Voltage"),
            elapsed_milliseconds   = ProtoField.uint32("slim_s.client.stat.elapsed_milliseconds",
                                                       "Ellapsed milliseconds"),
            server_timestamp       = ProtoField.uint32("slim_s.client.stat.server_timestamp",
                                                       "Server timestamp"),
            error_code             = ProtoField.uint16("slim_s.client.stat.error_code", "Error code"),
         },
         
         ureq = {},

         alss = {
            packet_rev = ProtoField.uint8("slim_s.client.alss.packet_rev", "Packet revision", base.DEC),
            time       = ProtoField.uint32("slim_s.client.alss.time", "Time", base.DEC),
            lux        = ProtoField.uint32("slim_s.client.alss.lux", "Lux", base.DEC),
            channel_0  = ProtoField.uint16("slim_s.client.alss.channel_0", "Channel 0", base.DEC),
            channel_1  = ProtoField.uint16("slim_s.client.alss.channel_1", "Channel 1", base.DEC),
         },

         shut = {},
      },

      server = {
         len  = ProtoField.uint16("slim_s.server.length", "Length", base.DEC),
         code = ProtoField.string("slim_s.server.code", "Server Code"),
         data = ProtoField.bytes("slim_s.server.data", "Data", base.HEX),

         audc = {},

         aude = {
            s_pdif_enable = ProtoField.uint8("slim_s.server.aude.s_pdif_enable", "s/pdif enable", base.DEC),
            dac_enable    = ProtoField.uint8("slim_s.server.aude.dac_enable", "DAC enable", base.DEC),
         },

         audf = {},

         audg = {
            old_gain               = ProtoField.uint32("slim_s.server.audg.old_gain", "Old gain", base.DEC),
            old_gain_1             = ProtoField.uint32("slim_s.server.audg.old_gain_1", "Old gain (1)", base.DEC),
            digital_volume_control = ProtoField.uint8("slim_s.server.audg.digital_volume_control",
                                                      "Digital volume control", base.DEC),
            preamp                 = ProtoField.uint8("slim_s.server.audg.preamp", "Preamp", base.DEC),
            new_gain               = ProtoField.uint32("slim_s.server.audg.new_gain", "New gain", base.DEC),
            new_gain_1             = ProtoField.uint32("slim_s.server.audg.new_gain_1", "New gain (1)", base.DEC),
            sequence_number        = ProtoField.uint32("slim_s.server.audg.sequence_number",
                                                       "Sequence number", base.DEC),
         },

         audo = {},
         audp = {},
         audr = {},
         bdac = {},
         bled = {},
         body = {},
         brir = {},
         cont = {},
         grfb = {},
         grfd = {},
         grfe = {},
         i2cc = {},
         knoa = {},
         knob = {},
         ledc = {},
         rsps = {},
         rstx = {},
         rtcs = {},
         setd = {
            id = ProtoField.uint8("slim_s.server.setd.id", "Pref Id", base.DEC),
         },

         strm = {
            command             = ProtoField.string("slim_s.server.strm.command", "Command"),
            autostart           = ProtoField.string("slim_s.server.strm.autostart", "Autostart"),
            formatbyte          = ProtoField.string("slim_s.server.strm.formatbyte", "Format byte"),
            pcmsamplesize       = ProtoField.string("slim_s.server.strm.pcmsamplesize", "PCM sample size"),
         
            pcmsamplerate       = ProtoField.string("slim_s.server.strm.pcmsamplerate", "PCM sample rate"),
            pcmchannels         = ProtoField.string("slim_s.server.strm.pcmchannels", "PCM channels"),
            pcmendian           = ProtoField.string("slim_s.server.strm.pcmendian", "PCM endianess"),
            buffer_threshold    = ProtoField.uint8("slim_s.server.strm.buffer_threshold", "Buffer threshold"),

            s_pdif_auto         = ProtoField.uint8("slim_s.server.strm.s_pdif", "s/pdif"),
            transition_duration = ProtoField.uint8("slim_s.server.strm.transition_duration",
                                                   "Transition duration"),
            transition_type     = ProtoField.string("slim_s.server.strm.transition_type", "Transition type"),
            flags               = ProtoField.uint8("slim_s.server.strm.flags", "Flags", base.HEX),

            output_threshold    = ProtoField.uint8("slim_s.server.strm.output_threshold", "Output threshold"),
            slave_streams       = ProtoField.uint8("slim_s.server.strm.slave_streams", "Slave streams"),
            replay_gain         = ProtoField.uint32("slim_s.server.strm.replay_gain", "Replain gain"),
            server_port         = ProtoField.uint16("slim_s.server.strm.server_port", "Server port"),

            server_ip           = ProtoField.ipv4("slim_s.server.strm.server_ip", "Server IP"),
            request             = ProtoField.string("slim_s.server.strm.request", "Request"),
         },

         test = {},
         upda = {},
         updn = {},
         ureq = {},
         vers = {},
         vfdc = {},
         visu = {},
      },
   }

   local device_id_2_name = { nil,
                              'squeezebox', 'softsqueeze', 'squeezebox2',
                              'transporter', 'softsqueeze3', 'receiver',
                              'squeezeslave', 'controller', 'boom', 'softboom',
                              'squeezeplay' }

   local dsco_reason_2_name = { [0] = 'Connection closed normally', 
                                [1] = 'Connection reset by local host',
                                [2] = 'Connection reset by remote host',
                                [3] = 'Connection is no longer able to work',
                                [4] = 'Connection timed out' }
   
   local pref_id_2_name = { [0] = 'playername',
                            [1] = 'digital_output_encoding',
                            [2] = 'world_clock_output',
                            [3] = 'power_off_dac',
                            [4] = 'disable_dac',
                            [5] = 'fxloop_source',
                            [6] = 'fxloop_clock' }

   local stat_event_2_name = { vfdc = "vfd received",
                               i2cc = "i2c command recevied",
                               TMa  = "AUTOSTART",
                               STMc = "CONNECT",
                               STMe = "ESTABLISH",
                               STMf = "CLOSE",
                               STMh = "ENDOFHEADERS",
                               STMp = "PAUSE",
                               STMr = "UNPAUSE",
                               STMt = "TIMER",
                               STMu = "UNDERRUN",
                               STMl = "FULL",
                               STMd = "DECODE_READY",
                               STMs = "TRACK_STARTED",
                               STMn = "NOT_SUPPORTED",
                               STMz = "end-of-stream", }
   
   local function addf(t, field, buf, offset, len, ...)
      len = len or buf:len() - offset
      local after = offset + len
      if buf:len() >= after then
         t:add(field, buf(offset, len), ...)
      end
      return after
   end


   -- Dissectors for client messages

   -- 'HELO'
   dissector.client["HELO"] = function (buf, pkt, t)
                                  local device_id = buf(0, 1):uint()
                                  local f = fields.client.helo
                                  local off = 0
                                  off = addf(t, f.device_id, buf, off, 1, device_id,
                                             "Device ID: " .. device_id ..
                                                " (" .. device_id_2_name[device_id] .. ")")
                                  off = addf(t, f.revision, buf, off, 1)
                                  off = addf(t, f.mac, buf, off, 6)
                                  if buf:len() >= 36 then
                                     off = addf(t, f.uuid, buf, off, 16)
                                  end
                                  off = addf(t, f.wlan_channellist, buf, off, 2)
                                  off = addf(t, f.bytes_received, buf, off, 8)
                                  off = addf(t, f.lang, buf, off, 2)
                                  off = addf(t, f.capabilities, buf, off)
                               end

   -- 'PRXY'
   dissector.client['PRXY'] = function (buf, pkt, t)
                                  local f = fields.client.prxy
                                  t:add(f.ip, buf(0, 4))
                                  t:add(f.port, buf(4, 2))
                               end

   -- 'ANIC'
   dissector.client['ANIC'] = function (buf, pkt, t)
                                  local f = fields.client.anic
                                  t:add(f.flags, buf(0,1))
                               end

   -- 'BODY'
   dissector.client['BODY'] = function (buf, pkt, t)
                                  local f = fields.client.body
                                  t:add(f.data, buf())
                               end

   -- 'BUTN'
   dissector.client['BUTN'] = function (buf, pkt, t)
                                  local f = fields.client.butn
                                  t:add(f.time, buf(0, 4))
                                  t:add(f.code, buf(4, 4))
                               end

   -- 'BYE!'
   dissector.client['BYE!'] = function (buf, pkt, t)
                                  local f = fields.client.bye
                                  t:add(f.code, buf(0, 1))
                               end

   -- 'DBUG'
   dissector.client['DBUG'] = function (buf, pkt, t)
                                  local t = fields.client.dbug
                                  t:add(f.data, buf())
                               end

   -- 'DSCO'
   dissector.client['DSCO'] = function (buf, pkt, t)
                                  local t = fields.client.dsco
                                  local reason = buf(0, 1):uint()
                                  t:add(t.reason, buf(0, 1), reason,
                                        "Reason: " .. reason .. " (" .. dsco_reason_2_name[reason] .. ")")
                               end

   -- 'IR  '
   dissector.client['IR  '] = function (buf, pkt, t)
                                  local f = fields.client.ir
                                  t:add(f.time, buf(0, 4))
                                  t:add(f.format, buf(4, 1))
                                  t:add(f.no_bits, buf(5, 1))
                                  t:add(f.code, buf(6, 4))
                               end
   -- 'KNOB'
   dissector.client['KNOB'] = function (buf, pkt, t)
                                  local f = fields.client.knob
                                  t:add(f.time, buf(0, 4))
                                  t:add(f.position, buf(4, 4))
                                  t:add(f.sync, buf(8, 1))
                               end

   -- 'META'
   dissector.client['META'] = function (buf, pkt, t)
                                  local f = fields.client.meta
                                  t:add(f.data, buf())
                               end

   -- 'RAWI'
   dissector.client['RAWI'] = function (buf, pkt, t)
                                  local f = fields.client.rawi
                                  t:add(f.data, buf())
                               end

   -- 'RESP'
   dissector.client['RESP'] = function (buf, pkt, t)
                                  local f = fields.client.resp
                                  t:add(f.data, buf())
                               end

   -- 'SETD'
   dissector.client['SETD'] = function (buf, pkt, t)
                                  local f = fields.client.setd
                                  local id = buf(0, 1):uint()
                                  local name = pref_id_2_name[id] or "unknown_pref"
                                  t:add(f.id, buf(0, 1), id,
                                        "Pref Id: " .. id .. " (" .. name .. ")" )
                                  t:add(f[name], buf(1))
                               end

   -- 'STAT'
   dissector.client["STAT"] = function (buf, pkt, t)
                                  local f = fields.client.stat
                                  event = buf(0, 4):string()
                                  local off = 0
                                  off = addf(t, f.event_code, buf, off, 4, event,
                                             "Event code: " .. event ..
                                                " (" .. (stat_event_2_name[event] or "unknown") .. ")")
                                  off = addf(t, f.num_crlf, buf, off, 1)
                                  off = addf(t, f.mas_initialized, buf, off, 1)
                                  off = addf(t, f.mas_mode, buf, off, 1)
                                  off = addf(t, f.fullness_a, buf, off, 4)
                                  off = addf(t, f.fullness_b, buf, off, 4)
                                  off = addf(t, f.bytes_received, buf, off, 8)
                                  off = addf(t, f.signal_strength, buf, off, 2)
                                  off = addf(t, f.jiffies, buf, off, 4)
                                  off = addf(t, f.output_buffer_size, buf, off, 4)
                                  off = addf(t, f.output_buffer_fullness, buf, off, 4)
                                  off = addf(t, f.elapsed_seconds, buf, off, 4)
                                  off = addf(t, f.voltage, buf, off, 2)
                                  off = addf(t, f.elapsed_milliseconds, buf, off, 4)
                                  off = addf(t, f.server_timestamp, buf, off, 4)
                                  off = addf(t, f.error_code, buf, off, 2)
                               end
   -- 'UREQ'
   dissector.client["UREQ"] = function(buf, pkt, t)
                               end

   -- 'ALSS'
   dissector.client["ALSS"] = function(buf, pkt, t)
                                  local f = fields.client.alss
                                  t:add(f.packet_rev, buf(0, 1))
                                  t:add(f.time, buf(1, 4))
                                  t:add(f.lux, buf(5, 4))
                                  t:add(f.channel_0, buf(9, 2))
                                  t:add(f.channel_1, buf(11, 2))
                               end
   
   -- 'SHUT'
   dissector.client["SHUT"] = function(buf, pkt, t)
                               end
   

   -- Dissectors for server messages

   dissector.server["audc"] = function (buf, pkt, t)
                              end

   dissector.server["aude"] = function (buf, pkt, t)
                                 local f = fields.server.aude
                                 t:add(f.s_pdif_enable, buf(0, 1))
                                 t:add(f.dac_enable, buf(1, 1))
                              end

   dissector.server["audf"] = function (buf, pkt, t)
                              end

   dissector.server["audg"] = function (buf, pkt, t)
                                 local f = fields.server.audg
                                 t:add(f.old_gain, buf(0, 4))
                                 t:add(f.old_gain_1, buf(4, 4))
                                 t:add(f.digital_volume_control, buf(8, 1))
                                 t:add(f.preamp, buf(9, 1))
                                 t:add(f.new_gain, buf(10, 4))
                                 t:add(f.new_gain_1, buf(14, 4))
                                 if buf:len() > 18 then
                                    t:add(f.sequence_number, buf(18, 4))
                                 end
                              end

   dissector.server["audo"] = function (buf, pkt, t)
                              end
   dissector.server["audp"] = function (buf, pkt, t)
                              end
   dissector.server["audr"] = function (buf, pkt, t)
                              end
   dissector.server["bdac"] = function (buf, pkt, t)
                              end
   dissector.server["bled"] = function (buf, pkt, t)
                              end
   dissector.server["body"] = function (buf, pkt, t)
                              end
   dissector.server["brir"] = function (buf, pkt, t)
                              end
   dissector.server["cont"] = function (buf, pkt, t)
                              end
   dissector.server["grfb"] = function (buf, pkt, t)
                              end
   dissector.server["grfd"] = function (buf, pkt, t)
                              end
   dissector.server["grfe"] = function (buf, pkt, t)
                              end
   dissector.server["i2cc"] = function (buf, pkt, t)
                              end
   dissector.server["knoa"] = function (buf, pkt, t)
                              end
   dissector.server["knob"] = function (buf, pkt, t)
                              end
   dissector.server["ledc"] = function (buf, pkt, t)
                              end
   dissector.server["rsps"] = function (buf, pkt, t)
                              end
   dissector.server["rstx"] = function (buf, pkt, t)
                              end
   dissector.server["rtcs"] = function (buf, pkt, t)
                              end

   dissector.server["setd"] = function (buf, pkt, t)
                                 local f = fields.server.setd
                                 local id = buf(0, 1):uint()
                                 local name = pref_id_2_name[id] or "unknown_pref"
                                 t:add(f.id, buf(0, 1), id,
                                       "Pref Id: " .. id .. " (" .. name .. ")")
                              end

   dissector.server["strm"] = function (buf, pkt, t)
                                 local f = fields.server.strm
                                 t:add(f.command, buf(0, 1))
                                 t:add(f.autostart, buf(1, 1))
                                 t:add(f.formatbyte, buf(2, 1))
                                 t:add(f.pcmsamplesize, buf(3, 1))

                                 t:add(f.pcmsamplerate, buf(4, 1))
                                 t:add(f.pcmchannels, buf(5, 1))
                                 t:add(f.pcmendian, buf(6, 1))
                                 t:add(f.buffer_threshold, buf(7, 1))

                                 t:add(f.s_pdif_auto, buf(8, 1))
                                 t:add(f.transition_duration, buf(9, 1))
                                 t:add(f.transition_type, buf(10, 1))
                                 t:add(f.flags, buf(11, 1))

                                 t:add(f.output_threshold, buf(12, 1))
                                 t:add(f.slave_streams, buf(13, 1))
                                 t:add(f.replay_gain, buf(14, 4))
                                 t:add(f.server_port, buf(18, 2))
                                 t:add(f.server_ip, buf(20, 4))
                                 if buf:len() > 24 then
                                    t:add(f.request, buf(24))
                                 end
                              end

   dissector.server["test"] = function (buf, pkt, t)
                                end
   dissector.server["upda"] = function (buf, pkt, t)
                                end
   dissector.server["updn"] = function (buf, pkt, t)
                                end
   dissector.server["ureq"] = function (buf, pkt, t)
                                end
   dissector.server["vers"] = function (buf, pkt, t)
                                end
   dissector.server["vfdc"] = function (buf, pkt, t)
                                end
   dissector.server["visu"] = function (buf, pkt, t)
                                end

   local function client_pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim_s.name
      local t = root:add(p_slim_s, buf())
      local f = fields.client
      t:add(f.code,  buf(0, 4))
      t:add(f.len,  buf(4, 4))
      
      local code = buf(0, 4):string()
      local d = dissector.client[code]
      if d then
         d(buf(8), pkt, t)
      else
         t:add(f.data, buf(8))
      end
   end

   function client_dissector(buf, pkt, root)
      local offset = 0
      while true do
         local buf_len = buf:len() - offset
         if buf_len < 8 then
            if buf_len > 0 then
               pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
               pkt.desegment_offset = offset
            end
            return
         end
            
         local pdu_len = buf(4 + offset, 4):uint() + 8
         if buf_len < pdu_len then
            pkt.desegment_len = pdu_len - buf_len
            pkt.desegment_offset = offset
            return
         end
         
         client_pdu_dissector(buf(offset, pdu_len), pkt, root)
         offset = offset + pdu_len
      end
   end

   local function server_pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim_s.name
      local t = root:add(p_slim_s, buf())
      local f = fields.server
      t:add(f.len, buf(0, 2))
      t:add(f.code, buf(2, 4))
      local code = buf(2, 4):string()
      local d = dissector.server[code]
      if d then
         d(buf(6), pkt, t)
      else
         t:add(f.data, buf(6))
      end
   end

   local function server_dissector(buf, pkt, root)
      local offset = 0
      while true do
         local buf_len = buf:len() - offset
         if buf_len < 2 then
            if buf_len == 0 then return end
            pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            pkt.desegment_offset = offset
            return
         end
         
         local pdu_len = buf(offset, 2):uint() + 2
         if buf_len < pdu_len then
            pkt.desegment_len = pdu_len - buf_len
            pkt.desegment_offset = offset
            return
         end
            
         server_pdu_dissector(buf(offset, pdu_len), pkt, root)
         offset = offset + pdu_len
      end
   end

   local slim_s_port = 3483

   function p_slim_s.dissector(buf, pkt, t)
      if pkt.dst_port == slim_s_port then
         return client_dissector(buf, pkt, t)
      else
         return server_dissector(buf, pkt, t)
      end
   end

   
   local function flatten_fields(f, q)
      q = q or {}
      if type(f) == "table" then
         for _, v in pairs(f) do
            flatten_fields(v, q)
         end
      else
         q[#q + 1] = f
      end
      return q
   end

   local function print_fields(n, f)
      if type(f) == "table" then
         print("looking for fields in " .. n)
         for k, v in pairs(f) do
            print_fields(k, v)
         end
      else
         print(" => " .. n .. " is a ProtoField")
      end
   end

   print_fields("root", fields)

   p_slim_s.fields = flatten_fields(fields)
   print("fields found: " .. #(p_slim_s.fields))

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(slim_s_port, p_slim_s)



end
