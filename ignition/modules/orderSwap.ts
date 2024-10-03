import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OrderSwapModule = buildModule("OrderSwapModule", (m) => {

    const order = m.contract("OrderSwap");

    return { order };
});

export default OrderSwapModule;
