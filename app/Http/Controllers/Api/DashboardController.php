<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Barang;
use App\Models\Penjualan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $totalProduk = Barang::count();
        $totalPenjualanHariIni = Penjualan::whereDate('created_at', Carbon::today())->count();
        $pendapatanHariIni = Penjualan::whereDate('created_at', Carbon::today())->sum('total');

        $stokMenipis = Barang::whereColumn('stok', '<=', 'minimal_stok')->count();
        $akanKadaluarsa = Barang::whereNotNull('tanggal_kadaluarsa')
                            ->where('tanggal_kadaluarsa', '<=', Carbon::now()->addDays(30))
                            ->count();

        return response()->json([
            'total_produk' => $totalProduk,
            'total_penjualan_hari_ini' => $totalPenjualanHariIni,
            'pendapatan_hari_ini' => $pendapatanHariIni,
            'stok_menipis' => $stokMenipis,
            'akan_kadaluarsa' => $akanKadaluarsa,
        ]);
    }

    public function alerts()
    {
        $stokMenipis = Barang::whereColumn('stok', '<=', 'minimal_stok')->get();
        $akanKadaluarsa = Barang::whereNotNull('tanggal_kadaluarsa')
                            ->where('tanggal_kadaluarsa', '<=', Carbon::now()->addDays(30))
                            ->get();

        return response()->json([
            'stok_menipis' => $stokMenipis,
            'akan_kadaluarsa' => $akanKadaluarsa,
        ]);
    }
}

