defmodule HelloNerves.Co2 do
  @address 0x31

  def get() do
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
        {:error, :i2c_nak} ->
          "i2c_nak"
      end

    I2C.close(ref)

    result
  end
end
