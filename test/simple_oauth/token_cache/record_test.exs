defmodule SimpleOAuth.TokenCache.RecordTest do
  use ExUnit.Case, async: true

  alias SimpleOAuth.TokenCache.Record

  describe "new/1" do
    test "success set updated_at with hlc timestamp" do
      assert %Record{
               provider: "google",
               expires_in: 7200,
               key: "test_key",
               value: "test_value",
               updated_at: %HLClock.Timestamp{}
             } =
               Record.new(%{
                 provider: "google",
                 key: "test_key",
                 value: "test_value",
                 expires_in: 7200
               })
    end
  end

  describe "expiring_status/1" do
    test "before expired in 20 minutes" do
      before_2_hours_from_now =
        DateTime.utc_now() |> DateTime.add(-2, :hour) |> DateTime.to_unix(:millisecond)

      record =
        %Record{
          provider: "google",
          key: "test_key",
          value: "test_value",
          expires_in: 7200,
          updated_at: %HLClock.Timestamp{time: before_2_hours_from_now}
        }

      assert :expired == Record.expiring_status(record)

      before_90_minutes_from_now =
        DateTime.utc_now() |> DateTime.add(-90, :minute) |> DateTime.to_unix(:millisecond)

      record =
        %Record{
          provider: "google",
          key: "test_key",
          value: "test_value",
          expires_in: 7200,
          updated_at: %HLClock.Timestamp{time: before_90_minutes_from_now}
        }

      assert :valid == Record.expiring_status(record)

      before_105_minutes_from_now =
        DateTime.utc_now() |> DateTime.add(-105, :minute) |> DateTime.to_unix(:millisecond)

      record =
        %Record{
          provider: "google",
          key: "test_key",
          value: "test_value",
          expires_in: 7200,
          updated_at: %HLClock.Timestamp{time: before_105_minutes_from_now}
        }

      assert {:expiring, seconds} = Record.expiring_status(record)
      assert is_integer(seconds)
    end

    test "always valid if expires_in is nil" do
      record =
        %Record{
          provider: "google",
          key: "test_key",
          value: "test_value",
          expires_in: nil,
          updated_at: %HLClock.Timestamp{
            time: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
          }
        }

      assert :valid == Record.expiring_status(record)
    end
  end
end
