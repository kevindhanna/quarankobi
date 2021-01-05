def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (day_3_count int)")
  client.query("SELECT id, count FROM visits").each do |v|
    client.query("UPDATE peeps SET day_3_count = #{v["count"]} WHERE id='#{v["id"]}'")
  end
end
