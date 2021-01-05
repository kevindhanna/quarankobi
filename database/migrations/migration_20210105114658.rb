def run(client)
  client.query("ALTER TABLE visits CHANGE ip id varchar(255)")
end
