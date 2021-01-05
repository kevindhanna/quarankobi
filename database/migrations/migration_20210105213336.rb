def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (day_9_twister int)")
  client.query("SELECT id, twister FROM day_9").each do |v|
    client.query("UPDATE peeps SET day_9_twister = #{v["twister"]} WHERE id='#{v["id"]}'")
  end
end
