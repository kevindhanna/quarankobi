def run(client)
  peeps = client.query("SELECT id, ip FROM peeps")
  peeps.each do |peep|
    if peep['id'] == nil
      client.query("UPDATE peeps SET id='#{SecureRandom.uuid}' where ip='#{peep['ip']}'")
    end
  end
end
