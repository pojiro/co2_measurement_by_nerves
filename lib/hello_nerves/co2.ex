defmodule HelloNerves.Co2 do
  use GenServer
  @address 0x31

  def start_link(ppm) do
    GenServer.start_link(__MODULE__, ppm, name: __MODULE__)
    get()
  end

  def offset(x) do
    GenServer.call(__MODULE__, {:offset, x})
  end

  def get() do
    IO.puts(inspect(GenServer.call(__MODULE__, :get)) <> " ppm")
    :timer.sleep(5000)
    get()
  end

  def prev() do
    GenServer.call(__MODULE__, :prev)
  end

  def _get() do
    alias Circuits.I2C

    {:ok, ref} = I2C.open("i2c-2")

    I2C.write(ref, @address, <<0x52>>)

    :timer.sleep(10)

    result =
      case I2C.read(ref, @address, 7) do
        {:ok, <<8,x,y,_,_,_,_>>=data} ->
          IO.inspect(data)
          x*256+y
        {:ok, <<255,_,_,_,_,_,_>>=data} ->
          IO.inspect(data)
        {:error, term} ->
          IO.inspect(term)
      end

    I2C.close(ref)

    result
  end

  def handle_call(:prev, _from, ppm) do
    {:reply, ppm, ppm}
  end

  def handle_call(:get, _from, _) do
    ppm = _get()
    {:reply, ppm, ppm}
  end

  def handle_call({:offset, offset}, _from, ppm) do
    {:reply, ppm + offset, ppm + offset}
  end
end
