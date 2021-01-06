def run(client)
  client.query("ALTER TABLE peeps ADD COLUMN (user_agent varchar(255))")
end
