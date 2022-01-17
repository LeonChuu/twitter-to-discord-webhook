defmodule TwitterToDiscordWebhookTest do
  use ExUnit.Case, async: true
  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end


  test "Basic normal functioning test", %{bypass: bypass} do
    test_hook=["127.0.0.1:#{bypass.port}/test"]
    Bypass.expect(bypass, fn conn ->
      IO.inspect(conn)
      Plug.Conn.resp(conn, 200, "{\"data\": [{\"entities\": {\"urls\":[{\"expanded_url\": \"test.com\"}]}}]}")
    end)

    Bypass.expect(bypass, "POST", "/test", fn conn ->
      IO.inspect(conn)
      Plug.Conn.resp(conn, 200, "{}")
    end)
    test_id=["test"]
    config = BotConfig.new(test_id,test_hook,10000,"testtoken")
    IO.inspect(config)
    resp = TwitterToDiscordWebhook.process(config,"127.0.0.1:#{bypass.port}")
    IO.inspect("resp")
    IO.inspect(resp)
    assert resp == :ok
  end


  test "error test Twitter API", %{bypass: bypass} do
    test_hook=["127.0.0.1:#{bypass.port}/test"]
    Bypass.expect(bypass, fn conn ->
      IO.inspect(conn)
      Plug.Conn.resp(conn, 400, "{\"data\": [{\"entities\": {\"urls\":[{\"expanded_url\": \"test.com\"}]}}]}")
    end)

    test_id=["test"]
    config = BotConfig.new(test_id,test_hook,10000,"testtoken")
    IO.inspect(config)
    assert TwitterToDiscordWebhook.process(config,"127.0.0.1:#{bypass.port}") == :error
  end

  test "error test Discord API", %{bypass: bypass} do
    test_hook=["127.0.0.1:#{bypass.port}/test"]
    Bypass.expect(bypass, fn conn ->
      IO.inspect(conn)
      Plug.Conn.resp(conn, 200, "{\"data\": [{\"entities\": {\"urls\":[{\"expanded_url\": \"test.com\"}]}}]}")
    end)

    Bypass.expect(bypass, "POST", "/test", fn conn ->
      IO.inspect(conn)
      Plug.Conn.resp(conn, 400, "{}")
    end)
    test_id=["test"]
    config = BotConfig.new(test_id,test_hook,10000,"testtoken")
    IO.inspect(config)
    assert TwitterToDiscordWebhook.process(config,"127.0.0.1:#{bypass.port}") == :error
  end
end
