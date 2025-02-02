defmodule Exqlite.Basic do
  @moduledoc """
  A very basis API without lots of options to allow simpler usage for basic needs.
  """

  alias Exqlite.Connection
  alias Exqlite.Query
  alias Exqlite.Sqlite3
  alias Exqlite.Error
  alias Exqlite.Result

  def open(path) do
    Connection.connect(database: path)
  end

  def close(conn = %Connection{}) do
    with :ok <- Sqlite3.close(conn.db) do
      :ok
    else
      {:error, reason} -> {:error, %Error{message: reason}}
    end
  end

  def exec(conn = %Connection{}, stmt, args \\ []) do
    %Query{statement: stmt} |> Connection.handle_execute(args, [], conn)
  end

  def rows(exec_result) do
    case exec_result do
      {:ok, %Query{}, %Result{rows: rows, columns: columns}, %Connection{}} ->
        {:ok, rows, columns}

      {:error, %Error{message: message}, %Connection{}} ->
        {:error, message}
    end
  end

  def load_extension(conn, path) do
    exec(conn, "select load_extension(?)", [path])
  end

  def enable_load_extension(conn) do
    Sqlite3.enable_load_extension(conn.db, true)
  end

  def disable_load_extension(conn) do
    Sqlite3.enable_load_extension(conn.db, false)
  end
end
