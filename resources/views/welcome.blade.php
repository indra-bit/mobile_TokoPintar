<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - StockMaster</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e0f0ff 0%, #c3dafe 100%);
            color: #333;
        }

        nav {
            background: linear-gradient(135deg, #4A90E2 0%, #87CEEB 100%);
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }

        nav .logo {
            font-size: 24px;
            font-weight: bold;
        }

        nav .nav-links a {
            color: white;
            margin-left: 20px;
            text-decoration: none;
            font-weight: 500;
            padding: 8px 16px;
            border: 1px solid transparent;
            border-radius: 6px;
        }

        nav .nav-links a:hover {
            background-color: rgba(255, 255, 255, 0.2);
            border-color: white;
        }

        .hero {
            padding: 60px 20px;
            text-align: center;
        }

        .hero h1 {
            font-size: 40px;
            color: #2a2a2a;
        }

        .hero p {
            font-size: 18px;
            color: #444;
            max-width: 600px;
            margin: 20px auto;
        }

        .hero .btn {
            background: #4A90E2;
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
        }

        .hero .btn:hover {
            background: #357ab7;
        }
    </style>
</head>
<body>
    <nav>
        <div class="logo">
            <i class="fas fa-boxes"></i> StockMaster
        </div>
    </nav>

    <div class="hero">
        <h1>Selamat Datang di StockMaster</h1>
        <p>Sistem manajemen stok barang sederhana dan efisien untuk kebutuhan toko atau gudang Anda.</p>
        <a href="{{ route('login') }}" class="btn">
            <i class="fas fa-sign-in-alt"></i> Mulai Sekarang
        </a>
    </div>
</body>
</html>
