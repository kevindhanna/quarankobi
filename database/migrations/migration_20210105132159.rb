def run(client)
  client.query("ALTER TABLE day_11_history CHANGE ip id varchar(255)")
end
