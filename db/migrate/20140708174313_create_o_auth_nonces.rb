class CreateOAuthNonces < ActiveRecord::Migration
  def change
    create_table :o_auth_nonces do |t|
      t.string :nonce

      t.timestamps
    end
  end
end
