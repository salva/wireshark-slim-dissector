do

   -- obsolete and incomplete protocol reference:
   -- http://wiki.slimdevices.com/index.php/SlimProto_TCP_protocol

   local p_slim_s = Proto("slim_s", "SLIM-S")
   local f = {}

   f.req = {
      code = ProtoField.string("slim_s.request.code", "Request Code"),
      len  = ProtoField.uint32("slim_s.request.length", "Length", base.DEC),
      data = ProtoField.bytes("slim_s.request.data", "Data", base.HEX)
   }

   f.req.helo = {
      device_id = ProtoField.int8("slim_s.request.helo.device_id", "DeviceID", base.DEC),
      revision  = ProtoField.int8("slim_sc.request.helo.revision", "Revision", base.DEC),
      mac       = ProtoField.ether("slim_sc.request.helo.mac", "MAC"),
   }

   local function req_helo_dissector(buf, pkt, t)
      local f = f.req.helo
      t:add(f.device_id, buf(0, 1))
      t:add(f.revision, buf(1, 1))
      t:add(f.mac, buf(2, 6))
   end

   f.req.stat = {
      event_code = ProtoField.string("slim_s.request.stat.event_code", "EventCode")
   }

   local function req_stat_dissector(buf, pkt, t)
      local f = f.req.stat
      t:add(f.event_code, buf(0, 4))
   end

   local req_dissector = { ["HELO"] = req_helo_dissector,
                           ["STAT"] = req_stat_dissector }
   
   local function client_pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim_s.name
      local t = root:add(p_slim_s, buf())
      local f = f.req
      t:add(f.code,  buf(0, 4))
      t:add(f.len,  buf(4, 4))
      
      local code = buf(0, 4):string()
      local dissector = req_dissector[code]
      if dissector then
         dissector(buf(8), pkt, t)
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

   f.res = {
      len  = ProtoField.uint16("slim_s.response.length", "Length", base.DEC),
      code = ProtoField.string("slim_s.response.code", "Response Code"),
      data = ProtoField.bytes("slim_s.response.data", "Data", base.HEX),
   }

   local function server_pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim_s.name
      local t = root:add(p_slim_s, buf())
      local f = f.res
      t:add(f.len, buf(0, 2))
      t:add(f.code, buf(2, 4))
      t:add(f.data, buf(6))
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

   
   local function search_fields(f, q)
      q = q or {}
      if type(f) == "table" then
         for _, v in pairs(f) do
            search_fields(v, q)
         end
      else
         q[#q + 1] = f
      end
      return q
   end

   local function print_fields(n, f)
      if type(f) == "table" then
         print("looking for fields in " .. n .. "\n")
         for k, v in pairs(f) do
            print_fields(k, v)
         end
      else
         print(" => " .. n .. " is a ProtoField\n")
      end
   end

   print_fields("root", f)

   p_slim_s.fields = search_fields(f)

   print("fields found: " .. #(p_slim_s.fields) .. "\n")

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(slim_s_port, p_slim_s)



end
