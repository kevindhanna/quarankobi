def run(client)
  client.query("ALTER TABLE day_9 CHANGE ip id varchar(255)")
end
