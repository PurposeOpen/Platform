# == Schema Information
#
# Table name: transactions
#
#  id              :integer          not null, primary key
#  donation_id     :integer          not null
#  successful      :boolean          default(FALSE)
#  amount_in_cents :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  currency        :string(3)
#  external_id     :string(255)
#  invoice_id      :string(255)
#

