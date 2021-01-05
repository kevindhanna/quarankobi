def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (day_11_history varchar(10000))")
  client.query("SELECT id, history FROM day_11_history").each do |v|
    client.query("UPDATE peeps SET day_11_history = '#{v["history"]}' WHERE id='#{v["id"]}'")
  end
end
