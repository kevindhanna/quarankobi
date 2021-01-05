def run(client)
  client.query("ALTER TABLE day_6_answers CHANGE ip id varchar(255)")
end
