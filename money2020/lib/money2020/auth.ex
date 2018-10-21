defmodule Money2020.Plugs.Auth do
    import Plug.Conn

    def init(default), do: default

    def call(%Plug.Conn{params: params} = conn, _default) do
        user_id = Map.get(params, "From") |> String.slice(1..-1)

        assign(conn, :user_id, user_id)
    end

    def random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end
end