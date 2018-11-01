class OrdersController < ApplicationController
  def new
    @product = Product.find(params[:product_id])
    @order = Order.new
    @order.product_id = @product.id
    @amount = @product.price + @product.shipping_price
  end

  def show
    @order = Order.find(params[:id])
  end

  def create
    @product = Product.find(params[:product_id])

    @amount = @product.price + @product.shipping_price

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'aud'
    )

    @order = Order.new(order_params)
    @order.product_id = @product.id
    if @order.save
      redirect_to @order #change this to order confirmation path
    else
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:name, :address)
  end
end
