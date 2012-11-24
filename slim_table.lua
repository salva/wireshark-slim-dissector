
do
   local p_slim = Proto("slim", "SLIM")

   local dissectors = {}

   local fields = {
      client = {
         header = { { 'code',             'a4'     },
                    { 'len',              'u32'    },
                    { 'data',             'b*'     } },
           
         HELO   = { { 'device_id',        'u8',    h = "Device ID" },
                    { 'revision',         'u8'     },
                    { 'mac',              'ether', h = 'MAC address' },
                    { 'uuid',             'b16',   h = 'UUID' },
                    { 'wlan_channellist', 'b4',    h = 'WLAN channel list' },
                    { 'bytes_received',   'u64'    },
                    { 'language',         'a2'     },
                    { 'capabilities',     'a*'     } },
         
         PRXY   = { { 'ip',               'ipv4'   },
                    { 'port',             'u16'    } },
         
         ANIC   = { { 'flags',            'u8'     } },
         
         BODY   = { { 'data',             'a*'     } },
         
         BUTN   = { { 'time',             'u32'    },
                    { 'code',             'u32'    } },
         
      },

      server = {
         header = { { 'len',             'u16'     },
                    { 'code',            'a4'      },
                    { 'data',             'b*'     } },

      }
   }

   local function normalize_cmd_name(cmd)
      return cmd:match('^(%S+)%s*$'):lower()
   end

   local function name_to_human(name)
      name = name:gsub('_+', ' ')
      return name:sub(1,1):upper() .. name:sub(2)
   end

   -- type_desc table contains the name of the factory method from
   -- ProtoField and the size of the field or nil to indicate it runs
   -- until the end of the buffer
   local type_desc = { u8     = { 'uint8',   1 },
                       u16    = { 'uint16',  2 },
                       u32    = { 'uint32',  4 },
                       u64    = { 'uint64',  8 },
                       ['a*'] = { 'string'     },
                       a2     = { 'string',  2 },
                       a4     = { 'string',  4 },
                       ['b*'] = { 'bytes',     },
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

   for side, msgs in pairs(fields) do
      dissectors[side] = {}
      local path = "slim." .. side

      for cmd, fields in pairs(msgs) do

         local ncmd = normalize_cmd_name(cmd)
         local path = path .. "." .. ncmd

         dissectors[side][cmd] = function (buf, pkt, t)
                                    dissect_with_fields(fields, buf, pkt, t)
                                 end

         for ix, desc in ipairs(fields) do
            desc.parent = path
            fill_desc(desc)
            print("field " .. desc.path .. " processed")
         end
      end
   end

   dissectors.client.HELO = function (buf, pkt, t)
                               local f = fields.client.HELO
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
