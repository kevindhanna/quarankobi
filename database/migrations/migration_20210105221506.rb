def run(client)
  client.query("DROP TABLE day_11_history")
  client.query("DROP TABLE visits")
  client.query("DROP TABLE day_9")
  client.query("DROP TABLE day_6_answers")
end
