def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (day_6_answers varchar(255))")
  client.query("SELECT id, answers FROM day_6_answers").each do |v|
    client.query("UPDATE peeps SET day_6_answers = #{v["answers"]} WHERE id='#{v["id"]}'")
  end
end
