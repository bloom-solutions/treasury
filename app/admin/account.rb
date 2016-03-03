ActiveAdmin.register Plutus::Account, as: "Account" do

  TYPES = {
    "Asset" => "Plutus::Asset",
    "Liability" => "Plutus::Liability",
    "Equity" => "Plutus::Equity",
    "Revenue" => "Plutus::Revenue",
    "Expense" => "Plutus::Expense",
  }

  actions :all, except: [:destroy]
  permit_params :name, :type, :contra

  index do
    column(:type) { |account| TYPES.invert[account.type] }
    column :name
    column :balance
    actions
  end

  form do |f|
    inputs do
      f.input :name
      f.input :type, collection: TYPES, include_blank: false
    end
    actions
  end

  show do
    attributes_table do
      row(:type) { |account| TYPES.invert[account.type] }
      row :name
      row :contra
    end

    active_admin_comments

    table_for account.entries do
      column(:description)
    end

    # panel "New Entry" do
    #   render "admin/entries/new", account: resource
    # end
    panel "Credit #{account.name}" do
    #   form Plutus::Entry.new do |f|
    #     f.input :description
    #     f.input :date, as: :string, input_html: {class: "datepicker"}
    #     f.semantic_fields_for :credits do |credit|
    #       credit.inputs "Credit 1" do
    #         credit.input :account_name, collection: Plutus::Account.all.pluck(:name)
    #         credit.input :amount
    #       end
    #       credit.inputs "Credit 2" do
    #         credit.input :account_name, collection: Plutus::Account.all.pluck(:name)
    #         credit.input :amount
    #       end
    #     end
    #   end
    end
  end

end
