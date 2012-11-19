do

   -- obsolete and incomplete protocol reference:
   -- http://wiki.slimdevices.com/index.php/SlimProto_TCP_protocol

   local p_slim_sc = Proto("slim_sc", "SLIM-SC")
   local p_slim_ss = Proto("slim_ss", "SLIM-SS")

   local p_slim_s = Proto("slim_s", "SLIM-S")

   function p_slim_s.dissector(buf, pkt, t)
      if pkt.dst_port == 3484 then
         return p_slim_sc.dissector(buf, pkt, t)
      else
         return p_slim_ss.dissector(buf, pkt, t)
      end
   end

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(3484, p_slim_s)

   do 
      local f_helo_device_id = ProtoField.int8("slim_sc.helo.device_id", "DeviceID", base.DEC)
      local f_helo_revision  = ProtoField.int8("slim_sc.helo.revision", "Revision", base.DEC)
      local f_helo_mac       = ProtoField.ether("slim_sc.helo.mac", "MAC")

      local function helo_dissector(buf, pkt, t)
         t:add(f_helo_device_id, buf(0, 1))
         t:add(f_helo_revision, buf(1, 1))
         t:add(f_helo_mac, buf(2, 6))
      end

      local f_stat_event_code = ProtoField.stringz("slim_sc.stat.event_code", "EventCode")

      local function stat_dissector(buf, pkt, t)
         t:add(f_stat_event_code, buf(0, 4))
      end

      local cmd_dissector = { ["HELO"] = helo_dissector,
                              ["STAT"] = stat_dissector }

      local f_cmd  = ProtoField.stringz("slim_sc.command", "Command")
      local f_len  = ProtoField.uint32("slim_sc.length", "Length", base.DEC)
      local f_data = ProtoField.bytes("slim_sc.data", "Data", base.HEX)

      p_slim_sc.fields = { f_helo_device_id, f_helo_revision, f_helo_mac,
                           f_stat_event_code,
                           f_cmd, f_len, f_data }

      local function pdu_slim_sc_dissector(buf, pkt, root)
         pkt.cols.protocol = p_slim_sc.name
         local data_len = buf(4, 4):uint()
         local t = root:add(p_slim_sc, buf())
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

      function p_slim_sc.dissector(buf, pkt, root)
         print("dissecting SLIM-SC\n")
         local offset = 0
         while true do
            local buf_len = buf:len() - offset
            -- print("dissecting offset: " .. offset .. ", buf_len: " ..buf_len .. "\n")
            if buf_len < 8 then
               if buf_len == 0 then return end
               pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
               -- print("requesting one more segment: " .. DESEGMENT_ONE_MORE_SEGMENT .. "\n")
               pkt.desegment_offset = offset
               return
            end
            
            local pdu_len = buf(4 + offset, 4):uint() + 8
            if buf_len < pdu_len then
               pkt.desegment_len = pdu_len - buf_len
               pkt.desegment_offset = offset
               return
            end
            
            pdu_slim_sc_dissector(buf(offset, pdu_len), pkt, root)
            offset = offset + pdu_len
         end
      end

      local tcp_encap_table = DissectorTable.get("tcp.port")
      tcp_encap_table:add(3483, p_slim_sc)
   end

   do

      local f_len = ProtoField.uint16("slim_ss.length", "Length", base.DEC)
      local f_cmd = ProtoField.string("slim_ss.command", "Command")
      local f_data = ProtoField.bytes("slim_ss.data", "Data", base.HEX)

      p_slim_ss.fields = { f_len, f_cmd, f_data }

      local function pdu_slim_ss_dissector(buf, pkt, root)
         pkt.cols.protocol = p_slim_ss.name
         local data_len = buf(0, 2):uint()
         local t = root:add(p_slim_ss, buf())
         t:add(f_len, buf(0, 2))
         t:add(f_cmd, buf(2, 4))
      end

      function p_slim_ss.dissector(buf, pkt, root)
         print("dissecting SLIM-SS\n")
         local offset = 0
         while true do
            local buf_len = buf:len() - offset
            if buf_len < 2 then
               if buf_len == 0 then return end
               pkt.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
               pkt.desegment_offset = offset
               return
            end

            local pdu_len = buf(offset, 2):uint() + 6
            if buf_len < pdu_len then
               pkt.desegment_len = pdu_len - buf_len
               pkt.desegment_offset = offset
               return
            end
            
            pdu_slim_ss_dissector(buf(offset, pdu_len), pkt, root)
            offset = offset + pdu_len
         end
      end

   end
end
