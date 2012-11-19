do

   -- obsolete and incomplete protocol reference:
   -- http://wiki.slimdevices.com/index.php/SlimProto_TCP_protocol

   local p_slim = Proto("slim", "SLIM")

   local f_helo_device_id = ProtoField.int8("slim.helo.device_id", "DeviceID", base.DEC)
   local f_helo_revision  = ProtoField.int8("slim.helo.revision", "Revision", base.DEC)
   local f_helo_mac       = ProtoField.ether("slim.helo.mac", "MAC")

   local function helo_dissector(buf, pkt, t)
      t:add(f_helo_device_id, buf(0, 1))
      t:add(f_helo_revision, buf(1, 1))
      t:add(f_helo_mac, buf(2, 6))
   end

   local f_stat_event_code = ProtoField.stringz("slim.stat.event_code", "EventCode")

   local function stat_dissector(buf, pkt, t)
      t:add(f_stat_event_code, buf(0, 4))
   end

   local cmd_dissector = { ["HELO"] = helo_dissector,
                           ["STAT"] = stat_dissector }

   local f_cmd  = ProtoField.stringz("slim.command", "Command")
   local f_len  = ProtoField.uint32("slim.length", "Length", base.DEC)
   local f_data = ProtoField.bytes("slim.data", "Data", base.HEX)

   p_slim.fields = { f_helo_device_id, f_helo_revision, f_helo_mac,
                     f_stat_event_code,
                     f_cmd, f_len, f_data }

   local function pdu_dissector(buf, pkt, root)
      pkt.cols.protocol = p_slim.name
      local data_len = buf(4, 4):uint()
      local t = root:add(p_slim, buf(0, pdu_len))
      t:add(f_cmd,  buf(0, 4))
      t:add(f_len,  buf(4, 4))

      local cmd = buf(0, 4):stringz()
      local cd = cmd_dissector[cmd]
      if cd then
         cd(buf(8, data_len), pkt, t)
      else
         t:add(f_data, buf(8, data_len))
      end
   end

   function p_slim.dissector(buf, pkt, root)
      local offset = 0
      while true do
         local buf_len = buf:len() - offset
         -- print("dissecting offset: " .. offset .. ", buf_len: " ..buf_len .. "\n")
         if buf_len < 8 then
            if buf_len == 0 then return end
            pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            -- print("requesting one more segment: " .. DESEGMENT_ONE_MORE_SEGMENT .. "\n")
            pkt.desegment_offset = offset
         end

         local pdu_len = buf(4 + offset, 4):uint() + 8
         if buf_len < pdu_len then
            pkt.desegment_len = pdu_len - buf_len
            pkt.desegment_offset = offset
            return
         end

         pdu_dissector(buf(offset, pdu_len), pkt, root)
         offset = offset + pdu_len
      end
   end

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(3483, p_slim)
end
