require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode / .decode" do
    it "round-trips the payload and adds iat and exp claims" do
      token = described_class.encode({ sub: 42 })
      payload = described_class.decode(token)

      expect(payload[:sub]).to eq(42)
      expect(payload[:iat]).to be_within(2).of(Time.current.to_i)
      expect(payload[:exp]).to be_within(2).of(24.hours.from_now.to_i)
    end
  end

  describe ".decode" do
    it "returns nil for a blank token" do
      expect(described_class.decode(nil)).to be_nil
      expect(described_class.decode("")).to be_nil
    end

    it "returns nil for a malformed token" do
      expect(described_class.decode("no.es.un.jwt")).to be_nil
    end

    it "returns nil for an expired token" do
      token = described_class.encode({ sub: 1 }, exp: 1.minute.ago)
      expect(described_class.decode(token)).to be_nil
    end

    it "returns nil for a token signed with another secret" do
      token = JWT.encode({ sub: 1, exp: 1.hour.from_now.to_i }, "otro-secreto", "HS256")
      expect(described_class.decode(token)).to be_nil
    end
  end
end
