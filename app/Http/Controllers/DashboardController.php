<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use App\Models\Transaksi;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        // --- Logika Notifikasi Stok Rendah ---
        $stokHampirHabis = Barang::whereColumn('stok', '<=', 'minimal_stok')->get();

        // --- Logika Notifikasi Kadaluarsa ---
        $tanggalPeringatan = Carbon::now()->addDays(30);
        $barangAkanKadaluarsa = Barang::whereNotNull('tanggal_kadaluarsa')
                                    ->where('tanggal_kadaluarsa', '<=', $tanggalPeringatan)
                                    ->get();

        // --- Data Laporan Penjualan dengan Filter ---
        $periode = $request->periode;
        $start_date = $request->start_date;
        $end_date = $request->end_date;

        $query = Transaksi::query();
        if ($start_date && $end_date) {
            $query->whereBetween('created_at', [$start_date, $end_date]);
        } elseif ($periode == 'harian') {
            $query->whereDate('created_at', now()->toDateString());
        } elseif ($periode == 'mingguan') {
            $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]);
        } elseif ($periode == 'bulanan') {
            $query->whereMonth('created_at', now()->month);
        }

        $transaksis = $query->orderByDesc('created_at')->paginate(15);

        // Grafik penjualan
        $grouped = $query->get()->groupBy(function($item) {
            return $item->created_at->format('d-m-Y');
        });
        $labels = $grouped->keys()->toArray();
        $data = $grouped->map(function($items) {
            return $items->sum('total_harga');
        })->values()->toArray();

        $labels = array_reverse($labels);
        $data = array_reverse($data);

        $total = $query->sum('total_harga');

        // --- Data Laporan Inventaris ---
        $barangs = Barang::orderBy('nama_barang', 'asc')->paginate(50);
        $totalNilaiInventaris = Barang::sum(DB::raw('harga * stok'));

        // --- Data Lainnya ---
        $totalBarang = Barang::count();
        $totalTransaksi = Transaksi::count();

        return view('dashboard', [
            'totalBarang' => $totalBarang,
            'totalTransaksi' => $totalTransaksi,
            'stokHampirHabis' => $stokHampirHabis,
            'barangAkanKadaluarsa' => $barangAkanKadaluarsa,
            'transaksis' => $transaksis,
            'total' => $total,
            'labels' => $labels,
            'data' => $data,
            'barangs' => $barangs,
            'totalNilaiInventaris' => $totalNilaiInventaris
        ]);
    }
}
