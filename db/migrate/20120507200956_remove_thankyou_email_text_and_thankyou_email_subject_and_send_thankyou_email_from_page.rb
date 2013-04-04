class RemoveThankyouEmailTextAndThankyouEmailSubjectAndSendThankyouEmailFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :thankyou_email_text
    remove_column :pages, :thankyou_email_subject
    remove_column :pages, :send_thankyou_email
  end

  def down
    add_column :pages, :send_thankyou_email, :boolean
    add_column :pages, :thankyou_email_subject, :string
    add_column :pages, :thankyou_email_text, :text
  end
end
