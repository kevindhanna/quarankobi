def run(client)
  client.execute("create table peeps (ip varchar(100), day int, completed boolean, reached varchar(100), name varchar(255))")
  client.execute("create table visits (ip varchar(100), count int)")
  client.execute("create table day_6_answers (ip varchar(100), answers varchar(255))")
  client.execute("create table day_11_history (ip varchar(100), history varchar(10000))")
end
