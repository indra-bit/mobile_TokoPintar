<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Penjualan;
use App\Models\Transaksi;
use App\Models\Barang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PenjualanController extends Controller
{
    public function index()
    {
        $penjualan = Penjualan::with('transaksis.barang')->latest()->paginate(15);
        return response()->json($penjualan);
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.barang_id' => 'required|exists:barangs,id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.harga' => 'required|numeric',
        ]);

        try {
            DB::beginTransaction();

            // Calculate total
            $total = 0;
            foreach ($request->items as $item) {
                $total += $item['jumlah'] * $item['harga'];
            }

            // Create Penjualan Let's use a simple code format
            $penjualan = Penjualan::create([
                'kode' => 'TRX-' . time(),
                'total' => $total,
            ]);

            // Create Transaksi and update stock
            foreach ($request->items as $item) {
                $barang = Barang::lockForUpdate()->find($item['barang_id']);

                if ($barang->stok < $item['jumlah']) {
                    throw new \Exception("Stok tidak mencukupi untuk barang: " . $barang->nama_barang);
                }

                Transaksi::create([
                    'penjualan_id' => $penjualan->id,
                    'barang_id' => $item['barang_id'],
                    'jumlah' => $item['jumlah'],
                    'total_harga' => $item['jumlah'] * $item['harga']
                ]);

                // Reduce stock
                $barang->decrement('stok', $item['jumlah']);
            }

            DB::commit();

            return response()->json([
                'message' => 'Transaksi berhasil',
                'penjualan' => $penjualan->load('transaksis.barang')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Transaksi gagal: ' . $e->getMessage()
            ], 400);
        }
    }

    public function show($id)
    {
        $penjualan = Penjualan::with('transaksis.barang')->findOrFail($id);
        return response()->json($penjualan);
    }
}

