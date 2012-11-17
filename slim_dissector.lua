do
   local p_slim = Proto("slim", "SlimProto")

   local f_cmd  = ProtoField.uint32("slim.command", "SlimCommand", base.DEC)
   local f_cmdt = ProtoField.string("slim.command_text", "Command_Text")
   local f_len  = ProtoField.uint32("slim.length", "Length", base.DEC)
   local f_data = ProtoField.string("slim.data", "Data")

   -- p_slim.fields = { f_cmd, f_len, f_data }
   p_slim.fields = { f_cmd, f_cmdt, f_len, f_data }

   function p_slim.dissector(buf, pkt, root)
      pkt.cols.protocol = "SLIM"
      local len = buf(4,4):uint()
      local t = root:add(p_slim, buf(0, len + 8))
      t:add(f_cmd,  buf(0, 4))
      t:add(f_cmdt, buf(0, 4))
      t:add(f_len,  buf(4, 4))
      t:add(f_data, buf(8, len))
   end

   local tcp_encap_table = DissectorTable.get("tcp.port")
   tcp_encap_table:add(3483, p_slim)
end
