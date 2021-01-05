def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (id varchar(255))")
end
