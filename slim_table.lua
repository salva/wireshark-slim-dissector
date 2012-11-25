
do
   local p_slim = Proto("slim", "SLIM")
   local p_slimp4 = Proto("slimp4", "SLIMP4")

   local fields = {
      slim = {
         client = {
            header   = { { 'code',             'a4'     },
                         { 'len',              'u32'    },
                         { 'packet_load',      'b*'     } },
            
            ['HELO'] = { { 'device_id',        'u8',    h = 'Device ID' },
                         { 'revision',         'u8'     },
                         { 'mac',              'ether', h = 'MAC address' },
                         { 'uuid',             'b16',   h = 'UUID' },
                         { 'wlan_channellist', 'b2',    h = 'WLAN channel list' },
                         { 'bytes_received',   'u64'    },
                         { 'language',         'a2'     },
                         { 'capabilities',     'a*'     } },
         
            ['PRXY'] = { { 'ip',               'ipv4'   },
                         { 'port',             'u16'    } },
            
            ['ANIC'] = { { 'flags',            'u8'     } },
         
            ['BODY'] = { { 'data',             'a*'     } },
         
            ['BUTN'] = { { 'time',             'u32'    },
                         { 'code',             'u32'    } },
            
            ['BYE!'] = { { 'code',             'u8'     } },
            
            ['DBUG'] = { { 'data',             'a*'     } },

            ['IR  '] = { { 'time',             'u32'    },
                         { 'format',           'u8'     },
                         { 'no_bits',          'u8'     },
                         { 'code',             'u32'    } },
         
            ['KNOB'] = { { 'time',             'u32'    },
                         { 'position',         'u32'    },
                         { 'sync',             'u8'     } },

            ['META'] = { { 'data',             'a*'     } },
            
            ['RESP'] = { { 'data',             'a*'     } },

            ['SETD'] = { { 'id',                      'u8' },
                         { 'playername',              'a*' },
                         { 'digital_output_encoding', 'u8' },
                         { 'world_clock_output',      'u8' },
                         { 'power_off_dac',           'u8' },
                         { 'disable_dac',             'u8' },
                         { 'fxloop_clock',            'u8' },
                         { 'unknown_pref',            'b*' } },
            
            ['STAT'] = { { 'event_code',       'a1'     },
                         { 'num_crlf',         'u8',    h = 'Num CRLF' },
                         { 'mas_initialized',  'u8'     },
                         { 'mas_mode',         'u8'     },
                         { 'fullness_a',       'u32'    },
                         { 'fullness_b',       'u32'    },
                         { 'bytes_received',   'u64'    },
                         { 'signal_strength',  'u16'    },
                         { 'jiffies',          'u32'    },
                         { 'output_buffer_size', 'u32'  },
                         { 'output_buffer_fullness', 'u32' },
                         { 'elapsed_seconds',  'u32'   },
                         { 'voltage',          'u16'   },
                         { 'elapsed_milliseconds', 'u32' },
                         { 'server_timestamp', 'u32'   },
                         { 'error_code',       'u16'   } },

            ['UREQ'] = {},

            ['ALSS'] = { { 'packet_rev',       'u8'    },
                         { 'time',             'u32'   },
                         { 'lux',              'u32'   },
                         { 'channel_0',        'u16'   },
                         { 'channel_1',        'u16'   } },
            
            ['SHUT'] = {},
         
         },

         server = {
            header   = { { 'len',             'u16'     },
                         { 'code',            'a4'      },
                         { 'packet_load',     'b*'      } },
            
            ['audc'] = { { 'clock_source',    'u8'      } },
            
            ['aude'] = { { 's_pdif_enable',   'u8'      },
                         { 'dac_enable',      'u8'      } },
            
            ['audf'] = { { 'fxloop_source',   'u8'      },
                         { 'fxloop_clock',    'u8'      } },
            
            ['audg'] = { { 'old_gain',        'u64'     },
                         { 'digital_volume_control', 'u8' },
                         { 'preamp',          'u8'      },
                         { 'new_gain',        'u64'     },
                         { 'sequence_number', 'u32'     } },
            
            ['audo'] = { { 'analog_out_mode', 'u8',     t = { [0] = 'headphone', 'sub out',
                                                              'always on', 'always off' } } },
            
            ['audp'] = { { 'line_in',         'u8',      h = 'Line in/digital input'} },
            
            ['audr'] = { { 'rolloff_slow',    'u8'      } },
            
            ['bdac'] = { { 'code',            'u8',     t = { [0] = 'dacreset', 'daci2cdata', 'daci2cdataend',
                                                              'dacdefault', 'daci2cgen', 'dacalsflood',
                                                              'dacwooferbq', 'dacwooferbqsub',
                                                              'daclineingain' } },
                         { 'length',          'u8'      },
                         { 'data',            'b*'      } },
            
            ['body'] = { { 'length',          'u32'     },
                         { 'body',            'a*'      } },
            
            ['brir'] = { { 'bkk',             'u8'      },
                         { 'gcp1',            'u8'      },
                         { 'gcp2',            'u8'      },
                         { 'bk2',             'u8'      },
                         { 'filament_v',      'u8'      },
                         { 'filament_p',      'u8'      },
                         { 'annode_v',        'u8'      },
                         { 'annode_p',        'u8'      } },
            
            ['cont'] = { { 'metaint',         'u32'     },
                         { 'loop',            'u8'      },
                         { 'count',           'u16'     },
                         { 'guids',           'b*'      } },
            
            ['grfb'] = { { 'brightnesscode',  'u16'     } },
            
            ['grfd'] = { { 'length',          'u16'     },
                         { 'data',            'b*'      } },
            
            ['grfe'] = { { 'data',            'b*'      } },
            
            ['i2cc'] = { { 'data',            'b*'      } },
            
            ['knoa'] = {},
            
            ['knob'] = { { 'list_index',      'u32'     },
                         { 'list_length',     'u32'     },
                         { 'knob_sync',       'u8'      },
                         { 'flags',           's8'      },
                         { 'width',           'u16'     },
                         { 'height',          's8'      },
                         { 'back_force',      's8'      } },
            
            ['ledc'] = { { 'color',           'u32'     },
                         { 'on_time',         'u16'     },
                         { 'off_time',        'u16'     },
                         { 'times',           'u8'      },
                         { 'transition',      'u8'      } },
            
            ['rsps'] = { { 'rate',            'u32'     } },
            
            ['rstx'] = { { 'data',            'b*'      } },
            
            ['rtcs'] = { { 'code',            'u8'      },
                         { 'data',            'b*'      } },
            
            ['setd'] = { { 'id',              'u8'      } },
            
            ['strm'] = { { 'command',         'a1'      },
                         { 'autostart',       'a1'      },
                         { 'formatbyte',      'a1'      },
                         { 'pcmsamplesize',   'a1'      },
                         { 'pcmsamplerate',   'a1'      },
                         { 'pcmchannels',     'a1'      },
                         { 'pcmendian',       'a1'      },
                         { 'buffer_threshold', 'u8'     },
                         { 's_pdif_auto',     'u8'      },
                         { 'transition_duration', 'u8'  },
                         { 'transition_type', 'a1'      },
                         { 'flags',           'u8'      },
                         { 'output_threshold', 'u8'     },
                         { 'slave_streams',   'u8'      },
                         { 'replay_gain',     'u32'     },
                         { 'server_port',     'u16'     },
                         { 'server_ip',       'ipv4'    },
                         { 'request',         'a*'      } },
            
            ['test'] = { { 'frame',           'b*'      } },
            
            ['upda'] = { { 'buf',             'b*'      } },
            
            ['updn'] = { { 'buf',             'b*'      } },
            
            ['ureq'] = {},
            
            ['vers'] = { { 'version',         'a*'      } },
            
            ['vfdc'] = { { 'data',            'b*'      } },
            
            ['visu'] = { { 'which',           'u8'      },
                         { 'count',           'u8'      },
                         { 'params_data',     'b*'      } },
            
         }
      }

      slimp4 = {}
   }

   local dissectors = {}
   local path_to_field = {}

   local function normalize_cmd_name(cmd)
      return cmd:match('^(%a+)'):lower()
   end

   local function name_to_human(name)
      name = name:gsub('_+', ' ')
      return name:sub(1,1):upper() .. name:sub(2)
   end

   -- type_desc table contains the name of the factory method from
   -- ProtoField and the size of the field or nil to indicate it runs
   -- until the end of the buffer
   local type_desc = { s8     = { 'int8',    1 },
                       u8     = { 'uint8',   1 },
                       u16    = { 'uint16',  2 },
                       u32    = { 'uint32',  4 },
                       u64    = { 'uint64',  8 },
                       ['a*'] = { 'string'     },
                       a1     = { 'string',  1 },
                       a2     = { 'string',  2 },
                       a4     = { 'string',  4 },
                       ['b*'] = { 'bytes',     },
                       b2     = { 'bytes',   2 },
                       b4     = { 'bytes',   4 },
                       b16    = { 'bytes',  16 },
                       ether  = { 'ether',   6 },
                       ipv4   = { 'ipv4',    4 } }

   local function fill_desc(desc)
      desc.name  = desc[1]
      desc.type  = desc[2]
      desc.path  = desc.parent .. "." .. desc.name
      desc.h     = desc.h or name_to_human(desc.name)
      local type_desc = type_desc[desc.type]
      if not type_desc then
         error("unknown type " .. desc.type .. " for " .. desc.path)
      end
      local factory = ProtoField[type_desc[1]]
      desc.len   = desc.len or type_desc[2]
      desc.field = factory(desc.path, desc.h, type_desc.base or desc.base)
      p_slim.fields[#(p_slim.fields) + 1] = desc.field
   end

   local function dissect_with_fields(f, buf, pkt, t)
      local len = buf:len()
      local off = 0;
      for i, desc in ipairs(f) do
         local rem = len - off
         local field_len = desc.len or rem
         if rem <= 0 then return end
         if field_len <= rem then
            t:add(desc.field, buf(off, field_len))
         end
         off = off + field_len
      end
   end

   for proto, tree_proto in pairs(fields) do

      for side, tree_side in pairs(tree_proto) do
         dissectors[side] = {}
         local path = proto .. "." .. side

         for cmd, tree_cmd in pairs(tree_side) do
            
            local ncmd = normalize_cmd_name(cmd)
            local path = path .. "." .. ncmd

            dissectors[side][cmd] = function (buf, pkt, t)
                                       dissect_with_fields(tree_cmd, buf, pkt, t)
                                    end

            for ix, desc in ipairs(tree_cmd) do
               desc.parent = path
               fill_desc(desc)
               path_to_field[desc.path] = desc
               print("field " .. desc.path .. " processed")
            end
         end
      end
   end

   dissectors.client.HELO = function (buf, pkt, t)
                               local f = fields.slim.client.HELO
                               local len = buf:len()
                               local off = 0
                               for i, desc in ipairs(f) do
                                  local rem = len - off
                                  local field_len = desc.len or rem
                                  if rem <= 0 then return end
                                  if desc.name ~= 'uuid' or len >= 36 then
                                     if field_len <= rem then
                                        t:add(desc.field, buf(off, field_len))
                                     end
                                     off = off + field_len
                                  end
                               end
                            end

   local pref_id_2_name = { [0] = 'playername',
                            [1] = 'digital_output_encoding',
                            [2] = 'world_clock_output',
                            [3] = 'power_off_dac',
                            [4] = 'disable_dac',
                            [5] = 'fxloop_source',
                            [6] = 'fxloop_clock' }

   dissectors.client.SETD = function (buf, pkt, t)
                               local len = buf:len()
                               if len >= 1 then
                                  t:add(fields.slim.client.SETD[1].field, buf(0, 1))
                                  if len > 1 then
                                     local id = buf(0, 1):uint()
                                     local path = 'slim.client.setd.' .. (pref_id_2_name[id] or 'unknown_pref')
                                     local f = path_to_field[path]
                                     if not f.len or f.len + 1 < len then
                                        t:add(f.field, buf(1, f.len))
                                     end
                                  end
                               end
                            end

   local function client_pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim.name
      local t = root:add(p_slim, buf())
      local h = dissectors.client.header(buf, pkt, t)
      local code = buf(0, 4):string()
      local d = dissectors.client[code]
      if d then
         d(buf(8), pkt, t)
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
      pkt.cols.protocol = p_slim.name
      local t = root:add(p_slim, buf())
      dissectors.server.header(buf, pkt, t)
      local code = buf(2, 4):string()
      local d = dissectors.server[code]
      if d then
         d(buf(6), pkt, t)
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

   local slim_port = 3483

   function p_slim.dissector(buf, pkt, t)
      if pkt.dst_port == slim_port then
         return client_dissector(buf, pkt, t)
      else
         return server_dissector(buf, pkt, t)
      end
   end

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(slim_port, p_slim)

   tcp_encap_table:add(9000, tcp_encap_table:get_dissector(80))
   tcp_encap_table:add(9001, tcp_encap_table:get_dissector(80))

end
